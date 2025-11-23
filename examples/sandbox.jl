using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using Cairo, Fontconfig
using Compose
using MarkovCats
using GraphPlot

# TODO: Add blackboxed kernel and see if we can get a full match
function example_wiring()
	@vars x y z
	g = Kernel(:g, (z | y));
	f = Kernel(:f, (y | x));
	test_morphisms = [f, g, copykernel(y), discardkernel(y)]

	w = possiblewiring(test_morphisms)
end

# TODO: Change layout and labels to make this easier to visualize
# Add nodelabels that match the show method of the ports
# Make this circular shell I guess? To show inputs and outputs. I wish there were a bipartite mode.
function plot(w::Wiring)
	g = w.wires
	nodelabel = collect(vertices(g))
	ctx = gplot(g, layout=circular_layout, nodelabel=nodelabel)
	draw(PNG("graph.png", 800, 600), ctx)
end

w = example_wiring()
plot(w)
