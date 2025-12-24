using Catlab.WiringDiagrams.DirectedWiringDiagrams
using Catlab.WiringDiagrams.MonoidalDirectedWiringDiagrams
import Catlab.WiringDiagrams.DirectedWiringDiagrams: WiringDiagram

WiringDiagram(expr::KernelExpr) = Box(expr.name, expr.inputs, expr.outputs)

function WiringDiagram(expr::AssignmentExpr)
	d = WiringDiagram(ins(expr), outs(expr))
	b = add_box!(d, WiringDiagram(expr.rhs))

	for i in ins(expr)
		src = findfirst( (x -> x==i).(ins(expr.lhs)) )
		if i in ins(expr.rhs)
			tgt = findfirst( (x -> x==i).(ins(expr.rhs)) )
			add_wire!(d, (input_id(d), src) => (b, tgt))
		else
			del_val = add_box!(d, mdisc(i))
			add_wire!(d, (input_id(d), src) => (del_val, 1))
		end
	end

	for i in outs(expr.rhs)
		src = findfirst( (x -> x==i).(outs(expr.rhs)) )
		tgt = findfirst( (x -> x==i).(outs(expr.lhs)) )
		add_wire!(d, (b, src) => (output_id(d), tgt))
	end
	return d
end

function WiringDiagram(expr::SumExpr)
	d = WiringDiagram(ins(expr), outs(expr))
	box_val = add_box!(d, WiringDiagram(expr.body))

	for i in 1:length(ins(expr))
		add_wire!(d, (input_id(d), i) => (box_val, i))
	end

	for i in outs(expr.body)
		inner_loc = findfirst( (x -> x==i).(outs(expr.body)) )
		if i in outs(expr)
			outer_loc = findfirst( (x -> x==i).(outs(expr)) )
			add_wire!(d, (box_val, inner_loc) => (output_id(d), outer_loc) )
		else
			del_id = add_box!(d, mdisc(i))
			add_wire!(d, (box_val, inner_loc) => (del_id, 1) )
		end
	end
	return d
end

function WiringDiagram(expr::ProductExpr)
	factor_wds = [WiringDiagram(k) for k in expr.factors]
	#factor_wds = [md.wiring_diagram for md in factor_mds]
	big_diagram = WiringDiagram(ins(expr), outs(expr))
	box_vals = [add_box!(big_diagram, diagram) for diagram in factor_wds]

	box_val = Dict(zip(expr.factors, box_vals))

	all_ins = vcat([ins(factor) for factor in expr.factors]...)

	# wire the outputs
	for factor in expr.factors
		for (idx, sym) in enumerate(outs(factor))
			out_location =	findfirst( (x -> x==sym).(outs(expr)) )
			num_syms = count( (x -> x==sym).(all_ins) )
			copy_val  = add_box!(big_diagram, mcopy(sym, num_syms+1))
			add_wire!(big_diagram, (box_val[factor], idx) => (copy_val, 1) )
			add_wire!(big_diagram, (copy_val, 1) => (output_id(big_diagram), out_location) )
			k = 2
			for in_factor in expr.factors
				if sym in ins(in_factor)
					input_index = findfirst( (x -> x==sym).(ins(in_factor)))
					add_wire!(big_diagram, (copy_val, k) => (box_val[in_factor], input_index))
					k = k+1
				end
			end
		end
	end

	for (input_index, input_sym) in enumerate(ins(expr))
		inner_input_locations = findall_inputs(input_sym, expr)
		num_copies = length(inner_input_locations)
		copy_val = add_box!(big_diagram, mcopy(input_sym, num_copies))
		add_wire!(big_diagram, (input_id(big_diagram), input_index) => (copy_val, 1) )
		k = 1
		for (box_expr, idx) in inner_input_locations
			add_wire!(big_diagram, (copy_val, k) => (box_val[box_expr], idx))
			k = k+1
		end
	end
	return big_diagram
end

mcopy(sym::Symbol, n::Int) = implicit_mcopy(Ports([sym]), n)
mcopy(sym::Symbol) = mcopy(sym, 2)
m_id(sym::Symbol)  = mcopy(sym, 1)
mdisc(sym::Symbol) = mcopy(sym, 0)
