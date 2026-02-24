using Catlab.Theories: FreeCartesianCategory
using Catlab.WiringDiagramExpressions
using GATlab.SymbolicModels: functor

"""Evaluate a FreeMarkovCategory.HomExpr using GATLab's built-in functor() semantic evaluator.
generators is a dict that maps the symbolic name of a HomExpr generator to its concrete implementation.
This function acts as a wrapper for functor(): functor()'s generators term requires access to
the actual HomExpr{:generator}. This function allows access to just the Symbol names of each generator.
"""
function evaluate_markov_expr(::Type{ObType}, ::Type{HomType},
        markov_expr, generators::Dict{Symbol, HomType}) where {ObType, HomType}
    terms = Dict(:Hom => expr -> generators[nameof(expr)])
    functor((ObType, HomType), markov_expr; terms=terms)
end

dictmap(f, d::Dict) = Dict(k => f(v) for (k,v) in d)

"""Run a block expression written in pipe notation given a generator dict
"""
function run_markov_program(
        ::Type{ObType},
        ::Type{HomType},
        expr::Expr,
        generators::Dict{Symbol, HomType})::Dict{Symbol, HomType} where {ObType, HomType}

    diagrams = expr |> parse_expr |> build_wiring_diagrams
    cart_exprs = dictmap(v -> to_hom_expr(FreeCartesianCategory, v), diagrams)
    diagrams2  = dictmap(to_wiring_diagram, cart_exprs)
    hom_exprs  = dictmap(v -> to_hom_expr(FreeMarkovCategory, v), diagrams2)
    return dictmap(e -> evaluate_markov_expr(ObType, HomType, e, generators), hom_exprs)

end
