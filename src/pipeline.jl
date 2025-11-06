module DSL
export @kerneldef , morphism_parsing_pipeline , pipenotation_to_morphisms , @vars , to_string

import Base: |

import Graphs
import GraphsMatching



function wires(ks::Vector{Kernel})
	inputs = vcat(input_ports.(ks))
	outputs = vcat(output_ports.(ks))
	function possible_match(output::Port, input::Port)
		(input.var == output.var) && !(input.box == output.box)
	end
	function possible_wires(output::Port, inputs::Vector{Port})
		[(output, input) for input in inputs if possible_match(output, input)]
	end
	vcat((o -> possible_wires(o, inputs)).(outputs))
end

"""
function morphism_parsing_pipeline(outer_name::Symbol, outer_signature::Signature, rhs::Expr)
	print("This is the outer_name\n")
	dump(outer_name)
	print("\nThis is the outer_signature\n")
	print(outer_signature)
	print("\nThis is the rhs\n")
	dump(rhs)
end
"""
function morphism_parsing_pipeline(lhs, rhs)
	dump(lhs)
	dump(rhs)
end

function pipenotation_to_morphisms(expr::Expr)
	print(expr)
end


end # module
