using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using Catlab.WiringDiagramExpressions
using MarkovCats
using GATlab.SymbolicModels

# expr = :( j(z,a,x,b|c,d) = sum(y)( g(y,z|x,c) * f(x|c) * k(b|x,a,c) * h(a|y) ) )

# @markov_code_block = :( begin
#     @markov_program begin
#     px = 𝓝([1, 2], [1 1; 1 2])
#     f  = GaussianKernel([2 0; 0 2], [2, 3], [4 5; 5 6])
#     @pipe_notation begin
#         py(y) = sum(x)( f(y|x) * px(x) )
#     end
#     end
# end)

# This was previously working before Claude's edits
# expr = :( py(y) = sum(x)( f(y|x) * px(x) ))
# 
# markov_expr = to_markov_expr(expr)
# println(markov_expr)
# 
# px_concrete = 𝓝([1, 2], [1 1; 1 2])
# f_concrete  = GaussianKernel([2 0; 0 2], [2, 3], [4 5; 5 6])
# 
# gen_map = Dict(:px => px_concrete, :f => f_concrete)
# py = functor((GaussStateSpace, GaussianKernel),
#               markov_expr;
#               terms = Dict(:Hom => expr -> gen_map[nameof(expr)]))
# 
# println(px_concrete)
# println(f_concrete)
# println(result)

# plot(diagram, "test.png")

# vvv ADDED BY CLAUDE vvv
@markov_program GaussStateSpace GaussianKernel begin
    px = 𝓝([1, 2], [1 1; 1 2])
    f  = GaussianKernel([2 0; 0 2], [2, 3], [4 5; 5 6])
    @pipe begin
        py(y) = sum(x)( f(y|x) * px(x) )
    end
end

println(py)
# ^^^ ADDED BY CLAUDE ^^^
