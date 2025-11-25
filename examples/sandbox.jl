using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using MarkovCats

@vars x y z
h = Kernel(:h, (z | x))
g = Kernel(:g, (z | y))
f = Kernel(:f, (y | x))
boundary_kernel = h
inner_kernels = [g, f, copykernel(y), discardkernel(y)]
kernel_list = KernelList(boundary_kernel, inner_kernels)

kernel_list |> PortGraph |>  matching |> MarkovCats.plot
