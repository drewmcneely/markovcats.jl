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
struct PortGraph
	outputs :: Vector{Port}
	inputs  :: Vector{Port}
	boundary_inputs  :: Vector{Port}
	boundary_outputs :: Vector{Port}
	edges :: Vector{Tuple{Port, Port}}
end

function add_edge!(pg::PortGraph, a::Port, b::Port)
	push!(pg.edges, (a,b))
	return pg
end

function PortGraph(
		outputs::Vector{Port}, 
		inputs::Vector{Port},
		boundary_inputs::Vector{Port},
		boundary_outputs::Vector{Port})
	PortGraph(outputs, inputs, boundary_inputs, boundary_outputs, Tuple{Port, Port}[])
end

function PortGraph(kl::KernelList)
	boundary_inputs = kl.boundary_kernel.inputports
	boundary_outputs = kl.boundary_kernel.outputports

	outputs = outputports(kl.inner_kernels)
	inputs = inputports(kl.inner_kernels)
	pg = PortGraph(outputs, inputs, boundary_inputs, boundary_outputs)

	for p1 in vcat(outputs, boundary_inputs) for p2 in inputs
			if wirable(p1, p2)
				add_edge!(pg, p1, p2)
			end
		end
	end

	for p1 in outputs for p2 in boundary_outputs
			if wirable(p1, p2)
				add_edge!(pg, p1, p2)
			end
		end
	end
	return pg
end

function nodes(pg::PortGraph)
	vcat(pg.boundary_inputs,
			 pg.outputs,
			 pg.inputs,
			 pg.boundary_outputs)
end
node_index(pg::PortGraph, p::Port)::Int = findfirst( (x -> x==p).(nodes(pg)) )
function edge_indices(pg::PortGraph, e::Tuple{Port, Port})
	(node_index(pg, e[1]) , node_index(pg, e[2]))
end
edge_indices(pg::PortGraph) =  [edge_indices(pg, e) for e in pg.edges]

Graphs.SimpleGraph(pg::PortGraph) = Graphs.SimpleGraph(Graphs.Edge.(edge_indices(pg)))
