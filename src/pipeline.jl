using Catlab.Theories: FreeCartesianCategory
using Catlab.WiringDiagramExpressions
using GATlab.SymbolicModels: functor

WiringDiagramExpressions.to_wiring_diagram(expr::Expr) = expr |> parse_expr |> WiringDiagram

to_cart_expr(expr::Expr) = to_hom_expr(FreeCartesianCategory, to_wiring_diagram(expr))

to_markov_expr(expr::Expr) = expr |> to_cart_expr |> to_wiring_diagram |> (d -> to_hom_expr(FreeMarkovCategory, d))

# vvv ADDED BY CLAUDE vvv
# Runtime helpers for @markov_program
####################################

"""Extract all KernelExpr nodes from a ParsedExpr tree."""
_extract_kernels(expr::KernelExpr) = [expr]
_extract_kernels(expr::AssignmentExpr) = vcat(_extract_kernels(expr.lhs), _extract_kernels(expr.rhs))
_extract_kernels(expr::SumExpr) = _extract_kernels(expr.body)
_extract_kernels(expr::ProductExpr) = vcat([_extract_kernels(f) for f in expr.factors]...)

"""Infer a mapping from variable names to Ob values by parsing the pipe expression
and using concrete kernel dimensions via `hom_to_obs`."""
function _infer_ob_map(pipe_expr::Expr, gen_map::Dict)
    parsed = parse_expr(pipe_expr)
    kernels = _extract_kernels(parsed)
    ob_map = Dict{Symbol, Any}()
    for k in kernels
        haskey(gen_map, k.name) || continue
        concrete = gen_map[k.name]
        (dom_ob, codom_ob) = hom_to_obs(concrete)
        if length(k.outputs) == 1
            ob_map[k.outputs[1]] = codom_ob
        end
        if length(k.inputs) == 1
            ob_map[k.inputs[1]] = dom_ob
        end
    end
    ob_map
end

"""Evaluate a Markov program: convert pipe expression to a HomExpr, infer Ob values,
and apply the functor to produce a concrete morphism."""
function evaluate_markov_program(::Type{ObType}, ::Type{HomType},
                                  pipe_expr::Expr, gen_map::Dict) where {ObType, HomType}
    markov_expr = to_markov_expr(pipe_expr)
    ob_map = _infer_ob_map(pipe_expr, gen_map)
    terms = Dict(
        :Hom => expr -> gen_map[nameof(expr)],
        :Ob  => expr -> ob_map[nameof(expr)]
    )
    functor((ObType, HomType), markov_expr; terms=terms)
end
# ^^^ ADDED BY CLAUDE ^^^

"""Evaluate a FreeMarkovCategory.HomExpr using GATLab's built-in functor() semantic evaluator.
generators is a dict that maps the symbolic name of a HomExpr generator to its concrete implementation.
This function acts as a wrapper for functor(): functor()'s generators term requires access to
the actual HomExpr{:generator}. This function allows access to just the Symbol names of each generator.
"""
function evaluate_markov_expr(::Type{ObType}, ::Type{HomType},
        markov_expr, generators::Dict{Symbol, Any}) where {ObType, HomType}
    terms = Dict(:Hom => expr -> generators[nameof(expr)])
    functor((ObType, HomType), markov_expr; terms=terms)
end
