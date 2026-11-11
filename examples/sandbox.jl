using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using Catlab.WiringDiagramExpressions
using MarkovCats
using GATlab.SymbolicModels

################################################################################
# The following is a working markov_program for composition with the CK equation
# TODO: Implement this as an integration test
# 
#
#
expr_block = :(begin
                   py(y) = Σ(x)( f(y|x) * px(x) )
                   pz(z) = Σ(y)( g(z|y) * py(y) )
               end)

px_concrete = 𝓝([1, 2], [1 1; 1 2])
f_concrete  = GaussianKernel([2 0; 0 2], [2, 3], [4 5; 5 6])
g_concrete  = GaussianKernel([1 2; 3 4], [2, 3], [2 0; 0 2])

gen_map = Dict(:px => px_concrete, :f => f_concrete, :g => g_concrete)
result = run_markov_program(GaussStateSpace,
                            GaussianKernel,
                            expr_block,
                            gen_map)
println(result)
##############################################################################


ex = :( bayes(x|y) = ( f(y|x) * p(x) ) / ( sum(x)(f(y|x)*p(x)) ) )

cex = parse_expr(ex)
println(cex)
