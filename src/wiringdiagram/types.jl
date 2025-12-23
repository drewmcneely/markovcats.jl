using Catlab.WiringDiagrams.MonoidalDirectedWiringDiagrams
""" Wrapper for Catlab.WiringDiagrams.MonoidalDirected.WiringDiagram
This is to give a clean interface that caters to the specific use case
of parsing probability expressions into wiring diagrams in a Markov category.
"""
struct MarkovDiagram
	wiring_diagram::WiringDiagram
end

function MarkovDiagram(expr::KernelExpr)
	wd = Box(expr.name, expr.inputs, expr.outputs)
	return MarkovDiagram(wd)
end

function MarkovDiagram(expr::ProductExpr)
	factor_mds = [MarkovDiagram(k) for k in expr.factors]
	factor_wds = [md.wiring_diagram for md in mds]
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

	# TODO: Wire the inputs

end

mcopy(sym::Symbol, n::Int) = implicit_mcopy(Ports(sym), n)
mcopy(sym::Symbol) = mcopy(sym, 2)
m_id(sym::Symbol)  = mcopy(sym, 1)
mdisc(sym::Symbol) = mcopy(sym, 0)
