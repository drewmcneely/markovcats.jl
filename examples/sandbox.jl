using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using MarkovCats

# @vars x y z
# 
# @kerneldef h(z|x)
# @kerneldef g(z|y)
# @kerneldef f(y|x)
# 
# boundary_kernel = h
# inner_kernels = [g, f, copykernel(y), discardkernel(y)]
# kernel_list = KernelList(boundary_kernel, inner_kernels)
# 
# kernel_list |> PortGraph |>  matching |> MarkovCats.plot


# exp = :( sum(x)( f(y|x) * px(x) ) )
# dump(exp)
# 
# exp = :( py(y) =  f(y|x) * px(x) )
# dump(exp)
# 
# exp = :( py(y) =  sum(x)(f(y|x) * px(x)) )
# dump(exp)

exp = :( py(y) = sum(x)(f(y|x) * px(x) ))
dump(parse_expr(exp))
