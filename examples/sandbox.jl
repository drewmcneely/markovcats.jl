using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

# using Catlab.WiringDiagramExpressions
using MarkovCats
# using GATlab.SymbolicModels
# using Debugger
using MarkovCats:MarkovEnv, normalize_diagram, to_markov_expr, obj_from_syms, wrap_cond
using MarkovCats.ThMarkovCategoryWithConditionals
using MarkovCats.FreeMarkovCategory
using Catlab.WiringDiagrams.DirectedWiringDiagrams

ex = :(begin
            pbar₁( x₁ )       = ∑(x₀)( f₁(x₁|x₀) * p₀(x₀) )
            joint₁( x₁ , y₁ ) = g₁(y₁|x₁) * pbar₁( x₁ )
            bayes₁( x₁ | y₁ ) = joint₁(x₁, y₁) / ∑(x₁)( joint₁(x₁, y₁) )
            p₁( x₁ )          = ∑(y₁)( bayes₁(x₁ | y₁) * meas(y₁) )

            pbar₂( x₂ )       = ∑(x₁)( f₂(x₂|x₁) * p₁(x₁) )
            joint₂( x₂ , y₂ ) = g₂(y₂|x₂) * pbar₂( x₂ )
            bayes₂( x₂ | y₂ ) = joint₂(x₂, y₂) / ∑(x₂)( joint₂(x₂, y₂) )
            p₂( x₂ )          = ∑(y₂)( bayes₂(x₂ | y₂) * meas(y₂) )
       end)

markov_env = ex |> parse_expr |> MarkovEnv{WiringDiagram} |> to_homexpr_env

## println(wiring_diagrams)
## for (name, entry) in markov_env
##     if entry isa HomDiagramEntry
##         println(name, ": ", to_markov_expr(entry.diagram))
##     # elseif entry isa CondDiagramEntry
##     #     plot(entry.boundary, string("boundary.png"))
##     #     plot(entry.inner_diagram, string("insides.png"))
##     else
##         println(name, ":")
##         println("\tboundary: ", to_markov_expr(entry.boundary))
##         println("\tinnards: ", to_markov_expr(entry.inner_diagram))
##     end
## end

p1exp = markov_env[:p₁].morphism
condname = p1exp.args[2].args[1]
inner_exp = markov_env[condname].innards

cond_vars = markov_env[condname].cond_vars
cond_obj = obj_from_syms(cond_vars)
# cond_objs = (x -> FreeMarkovCategory.Ob{:generator}([x],[])).(cond_vars)
# cond_obj  = otimes(cond_objs)

input_vars = markov_env[condname].input_vars
input_obj = obj_from_syms(input_vars)
# input_objs = (x -> FreeMarkovCategory.Ob{:generator}([x],[])).(input_vars)
# input_obj  = otimes(input_objs)
# input_obj = dom(inner_exp)

output_vars = markov_env[condname].output_vars
output_obj = obj_from_syms(output_vars)

wrap_cond(markov_env[condname])
# output_objs = (x -> FreeMarkovCategory.Ob{:generator}([x],[])).(output_vars)
# output_obj  = otimes(output_objs)

# cond_boundary = to_markov_expr(markov_env[condname].boundary)
# cond_innards = to_markov_expr(markov_env[condname].inner_diagram)
# cond_vars = markov_env[condname].cond_vars

# condexp = HomExpr{ThMarkovCategoryWithConditionals}.cond(cond_innards, cond_vars)

x = FreeMarkovCategory.Ob{:generator}([:x1],[])
y = FreeMarkovCategory.Ob{:generator}([:y1],[])
# f = markov_env.dict[:bayes1].morphism
markov_env.dict
