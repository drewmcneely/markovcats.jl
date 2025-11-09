using Cairo, Fontconfig
using Compose
using Graphs
using GraphsMatching
using GraphPlot

# """
# Wires get sent from outputs to inputs.
# This is with exception to the outer blackboxed kernel,
# which behaves like it's inside out.
# """
# struct Wire
# 	output::Port
# 	input::Port
# end

function wirable(output::Port, input::Port)
	(input.var == output.var) && !(input.kernel == output.kernel)
end

struct Wiring
	outputs::Vector{Port}
	inputs::Vector{Port}
	wires::SimpleGraph
end
function plot(w::Wiring)
    ctx = gplot(w.wires)                # Compose.Context
    # draw(SVG("graph.svg", 800, 600), ctx)   # safest: vector output
    draw(PNG("graph.png", 800, 600), ctx) # PNG also fine if Cairo is loaded
end

function possiblewiring(outputs::AbstractVector{<:AbstractPort}, inputs::AbstractVector{<:AbstractPort})::Wiring
	wires = [(n_o,n_i) for (n_o, o) in enumerate(outputs) for (n_i,i) in enumerate(inputs) if wirable(o,i)]
	graphedges = [(o, i+length(outputs)) for (o,i) in wires]
	g = SimpleGraph(length(outputs) + length(inputs))
	for (o,i) in graphedges
		add_edge!(g, o, i)
	end
	return Wiring(outputs, inputs, g)
end

function possiblewiring(ks::AbstractVector{<:AbstractKernel})
	possiblewiring(outputports(ks), inputports(ks))
end
