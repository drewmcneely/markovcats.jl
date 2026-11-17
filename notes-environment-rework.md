# Environment Rework Design Notes

Notes from Claude Code session, 2026-11-16.

## Problem Statement

The current environment is `Dict{Symbol, WiringDiagram}` -- a flat namespace that only
knows "name maps to diagram." This was fine when every statement was a simple assignment,
but conditionals need richer metadata: for each conditional we need to track both the
"inner" diagram (the numerator/joint) and the "outer" box (the black-box conditional
morphism), plus link them. The same limitation will block adding types, concrete primitive
bindings, etc.

## New Environment Design

Replace `Dict{Symbol, WiringDiagram}` with `Dict{Symbol, EnvironmentEntry}` where
`EnvironmentEntry` is an abstract type with subtypes. Each entry carries:

1. The kind of thing it is (external generator, derived assignment, conditional)
2. The wiring diagram (the "black box" view -- what other expressions see when they
   reference this name)
3. Any auxiliary data specific to the kind (for conditionals: inner joint diagram and
   variable partition; for primitives: could eventually be a concrete value or type
   annotation)

Current implementation in `src/wiringdiagram/types.jl`:

```julia
const MarkovEnv = Dict{Symbol, EnvironmentEntry}

abstract type EnvironmentEntry end

struct DiagramEntry <: EnvironmentEntry
    name::Symbol
    diagram::WiringDiagram
end

struct ConditionalEntry <: EnvironmentEntry
    name::Symbol
    outer_box::WiringDiagram
    inner_diagram::WiringDiagram
end
```

Notes:
- The `name` field is redundant with the dict key. Fine for debugging, but be aware of
  the consistency issue.
- `ConditionalEntry` might want a `conditioning_vars::Vector{Symbol}` field to make
  downstream code (Bayes rewrites, etc.) cleaner rather than recovering it from port lists.
- Consider whether `DiagramEntry` also covers external generators or whether those get a
  separate subtype. That distinction matters for validation.

## Conditionals as "Computed Generators"

Key insight: conditionals don't need to live *inside* another diagram's structure. A
conditional can be a black box in the outer diagram, just like any other generator. The
difference is its concrete value isn't provided by the user -- it's *computed* by
evaluating the inner diagram and then applying `cond()`.

Pipeline approach:
1. When encountering a conditional assignment, build the inner diagram (the joint/numerator)
   and store it in the `ConditionalEntry`. In the outer diagram (anything that references
   this conditional), it's just an opaque Box with the right ports.
2. The roundtrip normalization (wd -> cartesian expr -> wd -> markov expr) doesn't change.
   The conditional is just a named box to Catlab.
3. At evaluation time, process entries in dependency order. For a `ConditionalEntry`,
   first evaluate its inner diagram to get a concrete joint morphism, then apply `cond()`
   to get the conditional morphism, and insert that into the generators dict.

Why this is better than surgical HomExpr substitution: no need to understand
`to_hom_expr` internals, no pattern-matching inside HomExpr trees, and nesting works for
free (if a conditional's inner diagram references another conditional, dependency ordering
handles it).

Evaluation in `run_markov_program` changes from "evaluate all diagrams independently" to
"evaluate entries in topological order, where ConditionalEntry evaluation includes the
cond() step."

## Recursive Descent with Environment Threading

Pattern: every node in the recursion takes `(ParsedExpr, env)` and returns
`(WiringDiagram, new_env)`. Most node types pass env through unchanged; assignments and
conditionals return a new env with additional entries.

This threading is needed everywhere (not just top level) because a conditional can appear
nested inside a product or sum. When encountered mid-tree, it registers its inner diagram
in the env and replaces itself with a reference to the outer box. That modified env flows
back up and onward to sibling nodes.

### Method name: `lower`

Going from ParsedExpr -> (WiringDiagram, MarkovEnv). Called `lower` because it's
translating from a higher IR to a lower IR. `compile` is also reasonable. Can't use `parse`
(already used for Expr -> ParsedExpr). Overload on ParsedExpr subtypes: `lower(expr::KernelExpr, env)`, etc.

### Behavior per node type

- **KernelExpr** (leaf): Look up in env; if found return its diagram, otherwise create a
  Box. Env unchanged.
- **ProductExpr**: Fold over factors left-to-right, threading env through each. Each
  factor gets the env the previous factor returned. Combine diagrams. Return combined
  diagram + final env.
- **SumExpr**: Process body, pass through whatever env comes back. Wrap result in
  marginalization. Return with body's env.
- **AssignmentExpr**: Process RHS with current env -> (diagram, modified_env). Add new
  DiagramEntry to modified_env for LHS name. Return entry + updated env.
- **CondExpr**: Process inner/top expression -> (diagram, modified_env). Create
  ConditionalEntry with inner diagram + outer box. Add to env under a generated name.
  Return outer box diagram + updated env.
- **BlockExpr**: Fold over statements threading env. Final result is accumulated env.

### Immutability

Use `merge(env, Dict(:name => entry))` to create new Dicts rather than mutating with
`setindex!`. Not zero-cost but fine for the env sizes we'll have.

## Naming Nested Conditionals

Top-level assignments have a natural name from the LHS. Nested conditionals (e.g., a
conditional appearing as a factor in a product) don't. Solution: generated names.

Use Julia's `gensym` with a tag: `gensym("cond")` gives something like
`Symbol("##cond#257")` -- both unique and carries a readable hint for debugging.
Optionally derive a prefix from the kernel name in the numerator + gensym suffix.
Human-readable hints are valuable at this stage since you'll be staring at intermediate
representations a lot.
