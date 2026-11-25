using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

# using Catlab.WiringDiagramExpressions
using MarkovCats
# using GATlab.SymbolicModels
# using Debugger
using MarkovCats:MarkovEnv, normalize_diagram, to_markov_expr
using MarkovCats.ThMarkovCategoryWithConditionals
using MarkovCats.FreeMarkovCategory
using Catlab.WiringDiagrams.DirectedWiringDiagrams

ex = :(begin
            pbar1( x1 )       = ∑(x0)( f1(x1|x0) * p0(x0) )
            joint1( x1 , y1 ) = g1(y1|x1) * pbar1( x1 )
            bayes1( x1 | y1 ) = joint1(x1, y1) / ∑(x1)( joint1(x1, y1) )
            p1( x1 )          = ∑(y1)( bayes1(x1 | y1) * meas(y1) )

            pbar2( x2 )       = ∑(x1)( f2(x2|x1) * p1(x1) )
            joint2( x2 , y2 ) = g2(y2|x2) * pbar2( x2 )
            bayes2( x2 | y2 ) = joint2(x2, y2) / ∑(x2)( joint2(x2, y2) )
            p2( x2 )          = ∑(y2)( bayes2(x2 | y2) * meas(y2) )
       end)

markov_env = ex |> parse_expr |> MarkovEnv{WiringDiagram}

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

# p1exp = to_markov_expr(markov_env[:p1].diagram)
# condname = p1exp.args[2].args[1]
# cond_boundary = to_markov_expr(markov_env[condname].boundary)
# cond_innards = to_markov_expr(markov_env[condname].inner_diagram)
# cond_vars = markov_env[condname].cond_vars

# condexp = HomExpr{ThMarkovCategoryWithConditionals}.cond(cond_innards, cond_vars)

# x = FreeMarkovCategory.Ob{:generator}([:x1],[])
# y = FreeMarkovCategory.Ob{:generator}([:y1],[])
