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

function normalize_diagram(diagram::WiringDiagram)
    cart_exp = to_hom_expr(FreeCartesianCategory, diagram)
    normalized_diagram = to_wiring_diagram(cart_exp)
    return normalized_diagram
end

function to_markov_expr(diagram::WiringDiagram)
    normalized_diagram = normalize_diagram(diagram)
    return to_hom_expr(FreeMarkovCategory, normalized_diagram)
end

function to_markov_expr(entry::HomDiagramEntry)::HomExpr
    return HomExprEntry(to_markov_expr(entry))
end
