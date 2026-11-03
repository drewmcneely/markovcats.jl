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

"""
dictmap :: (v->w) -> Dict{k,v} -> Dict{k,w}
dictmap is a functorial map for dicts
"""
dictmap(f, d::Dict) = Dict(k => f(v) for (k,v) in d)

"""
Run a block expression written in pipe notation given a generator dict
The first argument, Type{ObType}, expects the name of the type eg. GaussStateSpace
The second argument, Type{HomType}, expects the name of the type eg. GaussianKernel
The third argument is the expression of the program, such as :(py(y) = sum(x)(f(y,x)))
The fourth argument is a dictionary of generators, that is, the map of symbols to concrete instances
For instance, this could be Dict(:f => 𝓝([0 0], [1 0; 0 1]))

This returns a dict of the resultant environment, mapping symbols to results, eg.
Dict(
"""
function run_markov_program(
        ::Type{ObType},
        ::Type{HomType},
        expr::Expr,
        generators::Dict{Symbol, HomType})::Dict{Symbol, HomType} where {ObType, HomType}

    diagrams = expr |> parse_expr |> build_wiring_diagrams # ::Dict{Symbol, WiringDiagram}
    cart_exprs = dictmap(v -> to_hom_expr(FreeCartesianCategory, v), diagrams)
    diagrams2  = dictmap(to_wiring_diagram, cart_exprs)
    hom_exprs  = dictmap(v -> to_hom_expr(FreeMarkovCategory, v), diagrams2)
    # This is a bad workaround to get a normalized wiring diagram.
    # It goes Expr -> WiringDiagram -> HomExpr{FreeCartesianCategory} -> WiringDiagram -> HomeExpr{FreeMarkovCategory}
    # Either the map to CartExpr or to the second WD does the normalization.
    # diagrammap = (v -> to_hom_expr(FreeCartesianCategory, v)) |> to_wiring_diagram |> (v -> to_hom_expr(FreeMarkovCategory, v))
    # hom_exprs = dictmap(diagrammap, diagrams)
    return dictmap(e -> evaluate_markov_expr(ObType, HomType, e, generators), hom_exprs)

end
