import Graphs
import GraphsMatching

@enum PortType inputport outputport

struct Port
	var::Var
	box::Symbol
	porttype::PortType
	index::Int
end


input_ports(k::Kernel) = [Port(var, k.name, inputport, index) for (index, var) in enumerate(inputs(k))]
output_ports(k::Kernel) = [Port(var, k.name, outputport) for var in outputs(k)]
input_ports(ks::Vector{Kernel}) = vcat(input_ports.(ks))
output_ports(ks::Vector{Kernel}) = vcat(output_ports.(ks))

function compatible(output::Port, input::Port)
	(input.var == output.var) && !(input.box == output.box)
end

function wires(output::Port, inputs::Vector{Port})
	@assert output.porttype == outputport
	for input in inputs
		@assert input.porttype == inputport
	end
	[(output, input) for input in inputs if compatible(output, input)]
end

function wires(outputs::Vector{Port}, inputs::Vector{Port})
	vcat((o -> wires(o, inputs)).(outputs))
end

function wires(ks::Vector{Kernel})
	inputs = input_ports(ks)
	outputs = output_ports(ks)
	wires(outputs, inputs)
end
