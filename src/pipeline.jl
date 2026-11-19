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

function normalize_diagram(diagram::WiringDiagram)
    cart_exp = to_hom_expr(FreeCartesianCategory, diagram)
    normalized_diagram = to_wiring_diagram(cart_exp)
    return normalized_diagram
end

function to_markov_expr(diagram::WiringDiagram)
    normalized_diagram = normalize_diagram(diagram)
    return to_hom_expr(FreeMarkovCategory, normalized_diagram)
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

    env = expr |> parse_expr |> MarkovEnv
    
    output_env = Dict{Symbol, HomType}()

    for (name, entry) in env
        if entry isa DiagramEntry
            cart_exp = to_hom_expr(FreeCartesianCategory, entry.diagram)
            normalized_diagram = to_wiring_diagram(cart_exp)
            markov_exp = to_hom_expr(FreeMarkovCategory, normalized_diagram)
            markov_result = evaluate_markov_expr(ObType, HomType, markov_exp, generators)
            output_env[name] = markov_result
        end
    end
    return output_env

end
