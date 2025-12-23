using Catlab.WiringDiagrams.MonoidalDirectedWiringDiagrams

function to_wiring_diagram(expr::AssignmentExpr)::WiringDiagram
end

function to_wiring_diagram(expr::SumExpr)::WiringDiagram
end

function to_wiring_diagram(expr::ProductExpr)::WiringDiagram
	inputs = boundary_inputs(expr)
	outputs = boundary_outputs(expr)
	wd = WiringDiagram(inputs, outputs)

	box_ids = [add_box!(wd, to_wiring_diagram(b)) for b in expr.factors]
	box_id = Dict(zip(expr.factors, box_ids))

	# TODO: Finish this
	add_wires!(wd, expr)
end

# TODO: Verify that the below is the correct algorithm
# TODO: Translate pseudocode
boundary_inputs(expr::ProductExpr) = unique(all_inputs(expr)) - outputs(expr)

""" Return an iterable of all the locations of the sym in the inner boxes
For instance, in exp = P(G|S,R)*P(S|R)*P(R),
find_inputs(:S, exp) will return
[ (box = id of P(G|S,R) and index = 1) ]

find_inputs(:R, exp) will return
[ (box = id of P(G|S,R) and index = 2),
	(box = id of   P(S|R) and index = 1) ]
"""
function find_inputs(sym::Symbol, expr)
	# TODO: Implement
end

# TODO: Translate pseudocode
function wire_input_symbol!(wd, sym, expr)
	kernel_inputs = find_inputs(i, expr)
	mcopy_id = mcopy(i, length(kernel_inputs))

	add_wire!(wd, (input_id(wd), index(i)) => (mcopy_id, 1)) # Wire boundary input to copy input

	for (copy_index, kernel_input) in enumerate(kernel_inputs)
		wire_target_loc = (getbox(kernel_input), getindex(kernel_input))
		add_wire!(wd, (mcopy_id, copy_index) => wire_target_loc)
	end
end

function wire_output_symbol!(wd, sym, expr)
	kernel_inputs = find_inputs(i, expr)
	mcopy_id = mcopy(i, length(kernel_inputs)+1)

	add_wire!(wd, (getbox(i), index_of_box(i)) => (mcopy_id, 1))
	add_wire!(wd, (mcopy_id, 1) => (output_id(wd), index(i)))

	for (copy_index, kernel_input) in enumerate(kernel_inputs)
		wire_target_loc = (getbox(kernel_input), getindex(kernel_input))
		add_wire!(wd, (mcopy_id, copy_index+1) => wire_target_loc)
	end
end

function add_wires!(wd::WiringDiagram, expr::ProductExpr)
	for i in boundary_inputs(expr)
		wire_input_symbol!(wd, i, expr)
	end
	for i in boundary_outputs(expr)
		wire_output_symbol!(wd, i, expr)
	end
end

to_wiring_diagram(expr::KernelExpr) = Box(
	expr.name,
	expr.inputs,
	expr.outputs)
