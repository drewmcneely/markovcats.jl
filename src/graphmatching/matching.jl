using Graphs
using GraphsMatching

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

# Edges go from outputs -> inputs, boundary_inputs -> inputs, or outputs -> boundary_outputs
mutable struct PortGraph
	outputs :: Vector{Port}
	inputs  :: Vector{Port}
	boundary_inputs  :: Vector{Port}
	boundary_outputs :: Vector{Port}
	edges :: Vector{Tuple{Port, Port}}
end

function PortGraph(outputs::Vector{Port}, inputs::Vector{Port}, boundary_inputs::Vector{Port}, boundary_outputs::Vector{Port})
	PortGraph(outputs, inputs, boundary_inputs, boundary_outputs, Tuple{Port, Port}[])
end
function add_edge!(pg::PortGraph, a::Port, b::Port)
	push!(pg.edges, (a,b))
	return pg
end

function Base.show(io::IO, pg::PortGraph)
	for p in pg.boundary_inputs
		show(io, p)
		print(" ")
	end
	print(" || ")
	for p in pg.outputs
		show(io, p)
		print(" ")
	end
	print("\n\n")
	for p in pg.inputs
		show(io, p)
		print(" ")
	end
	print(" || ")
	for p in pg.boundary_outputs
		show(io, p)
		print(" ")
	end
	print("\n\n")
	for (a,b) in pg.edges
		show(io, a)
		print(" -> ")
		show(io, b)
		print("\n")
	end
end

struct Wiring
	outputs::Vector{Port}
	inputs::Vector{Port}
	wires::SimpleGraph
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
