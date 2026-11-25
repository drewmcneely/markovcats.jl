using Catlab.Theories: FreeCartesianCategory
using Catlab.WiringDiagramExpressions
using GATlab.SymbolicModels: functor


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
        if entry isa HomEntry{WiringDiagram}
            cart_exp = to_hom_expr(FreeCartesianCategory, entry.diagram)
            normalized_diagram = to_wiring_diagram(cart_exp)
            markov_exp = to_hom_expr(FreeMarkovCategory, normalized_diagram)
            markov_result = evaluate_markov_expr(ObType, HomType, markov_exp, generators)
            output_env[name] = markov_result
        end
    end
    return output_env

end
