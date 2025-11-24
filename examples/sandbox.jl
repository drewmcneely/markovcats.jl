using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using Cairo, Fontconfig
using Compose
using MarkovCats
using GraphPlot
using Graphs

function plot(g::SimpleGraph)
	nodelabel = collect(vertices(g))
	ctx = gplot(g,
							layout=circular_layout,
							nodelabel=nodelabel)
	draw(PNG("graph2.png", 800, 600), ctx)
end

@vars x y z
h = Kernel(:h, (z | x))
g = Kernel(:g, (z | y))
f = Kernel(:f, (y | x))
boundary_kernel = h
inner_kernels = [g, f, copykernel(y), discardkernel(y)]
kernel_list = KernelList(boundary_kernel, inner_kernels)

kernel_list |> PortGraph |>  MarkovCats.plot
