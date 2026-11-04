# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Developer-Added Instructions

This project is primarily for learning. Do not make any edits yourself. Prefer instead to give guidance to help the dev implement himself. Start with general direction without code or pseudocode only (exception if there are specific niche Julia things that would be better to directly explain with Julia code), and when reprompted, give more specific examples/code for the dev to try.

## Project Overview

MarkovCats.jl is a Julia package that provides a macro-based embedded DSL for expressing probabilistic models using Markov category theory. Users write familiar probabilistic equations (e.g., Chapman-Kolmogorov); the package parses them into compositional string diagrams and evaluates them in a chosen backend (currently Gaussian kernels via linear algebra).

Based on the formalism from [Fritz's synthetic probability paper](https://arxiv.org/abs/1908.07021) (Notation 2.8) and [Hidden Markov Models and the Bayes Filter in Categorical Probability](https://arxiv.org/abs/2401.14669).

## Development Commands

```bash
# Activate and install dependencies (from Julia REPL, press ] for Pkg mode)
activate .
instantiate

# Run tests
julia --project=. -e 'using Pkg; Pkg.test()'

# Run a single test file
julia --project=. test/runtests.jl

# Run examples
julia --project=. examples/sandbox.jl
```

Julia 1.13+ is required. Key dependencies: Catlab (0.17.3), GATlab (0.2.2), LinearAlgebra.

## Architecture

### Compilation Pipeline

The core pipeline converts DSL surface syntax into executable morphisms through these stages:

1. **Julia Expr** -- user writes `py(y) = sum(x)( f(y|x) * px(x) )`
2. **ParsedExpr** (`src/parsedexpr/`) -- recursive descent parser (`parsing.jl`) converts `Expr` into an AST of `KernelExpr`, `AssignmentExpr`, `SumExpr`, `ProductExpr`, `BlockExpr` (defined in `types.jl`). `ProductExpr` constructor automatically topological-sorts its factors.
3. **WiringDiagram** (`src/wiringdiagram/constructors.jl`) -- each ParsedExpr type has a `WiringDiagram()` constructor that builds Catlab `DirectedWiringDiagram`s. Copy (`mcopy`) and discard (`mdisc`) morphisms are inserted to handle variable sharing and marginalization.
4. **HomExpr normalization** (`src/pipeline.jl`) -- the diagram is round-tripped: `WiringDiagram -> FreeCartesianCategory HomExpr -> WiringDiagram -> FreeMarkovCategory HomExpr` to normalize it.
5. **Backend evaluation** -- `evaluate_markov_expr()` uses GATlab's `functor()` to evaluate the symbolic HomExpr with concrete morphism implementations.

### Entry Point

`run_markov_program(ObType, HomType, expr, generators)` in `src/pipeline.jl` is the main programmatic API. It takes an object type, morphism type, a block expression, and a dictionary mapping generator names to concrete instances.

### Category Theory Layer (`src/categories/`)

- `theory.jl` -- defines `ThMarkovCategory` extending Catlab's `ThMonoidalCategoryWithDiagonals` and `FreeMarkovCategory` symbolic model
- `gauss.jl` -- implements `@instance ThMarkovCategory{GaussStateSpace, GaussianKernel}` with concrete linear algebra operations (compose = affine transform chaining, otimes = block-diagonal, mcopy = stacking identity matrices)
- `types.jl` -- abstract type hierarchy: `Morphism > MonoidalMorphism > SymmetricMonoidalMorphism > MarkovMorphism` (and parallel `CatObject` hierarchy). Currently unused but intended for future backends.

### DSL Macros (`src/dsl/macros.jl`)

Contains `@vars`, `@kernel`, `@kerneldef`, `@kerneleq` (stub), and `@markov_program` macros. The `@kernelassignments` macro is commented out (references removed types). `@markov_program` is a Claude-added macro.

### Kernel Syntax

The `|` operator in kernel signatures (e.g., `f(y|x)`) is parsed as Julia's bitwise OR, producing the pattern `[:y, Expr(:call, :|, :y, :x)]`. The `parse_kernel` function in `parsing.jl` handles this specific destructuring.

`sum`/`Σ` for marginalization uses Julia's curried call syntax: `sum(x)(body)` parses as `call(call(sum, x), body)`.

### Grammar Files

`grammar/` contains ANTLR4 grammar files (`ExprLexer.g4`, `ExprParser.g4`) and example `.mc` files. These define a standalone DSL syntax but are not currently used by the Julia code -- the package uses Julia macro-based parsing instead.

## Project Status

Early-stage development. The Gaussian backend works for simple pipeline compositions. Many test cases in `test/runtests.jl` are commented out. The `otimes` implementation in `gauss.jl` has a bug (references `ΣF`/`ΣG` instead of `Σf`/`Σg`).
