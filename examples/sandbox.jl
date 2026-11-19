using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using Catlab.WiringDiagramExpressions
using MarkovCats
using GATlab.SymbolicModels
using Debugger
using MarkovCats:MarkovEnv

ex = :(begin
            pbar(xnext)       = ∑(x)( f(xnext|x) * p(x) )
            joint( xnext, y ) = pbar( xnext ) * g( y | xnext )
            bayes(xnext | y)  = joint(xnext, y) / ∑(xnext)( joint( xnext, y ) )
            p_next( xnext )   = ∑(y)( bayes(xnext | y) * meas(y) )
       end)

wiring_diagrams = ex |> parse_expr |> MarkovEnv

println(wiring_diagrams)
