using Catlab.WiringDiagrams.DirectedWiringDiagrams
using Catlab.WiringDiagrams.MonoidalDirectedWiringDiagrams

function MarkovEnv(expr::BlockExpr)
    env = MarkovEnv()
    for assignment in expr.statements
        diagram, env = lower(assignment, env)
        # I don't think the below is needed anymore..?
        # env[nameof(assignment)] = diagram
    end
    #return symbol_table[nameof(expr.statements[end])]
    return env
end

# Obsolete
# WiringDiagram(expr::BlockExpr) = build_wiring_diagrams(expr)[nameof(expr.statements[end])]

function lower(expr::KernelExpr, env::MarkovEnv = MarkovEnv())::(WiringDiagram, MarkovEnv)
    if haskey(env, expr.name)
        return (env[expr.name], env)
    else
        return Box(expr.name, expr.inputs, expr.outputs)
    end
end

# Should not be needed if everything is wrapped in a begin..end block, correct..?
# build_wiring_diagrams(expr::AssignmentExpr) = MarkovEnv(symbol_table = Dict(nameof(expr) => WiringDiagram(expr)))

function lower(expr::AssignmentExpr, env::MarkovEnv = MarkovEnv())::(WiringDiagram, MarkovEnv)
  # FIXME: This code does not check environment for the LHS, and does not update environment
  # if the LHS has an overwrite. As written, I expect overwrites to just not happen.
	diagram = WiringDiagram(ins(expr), outs(expr))
  rhs_box, rhs_env = lower(expr.rhs, env)
	rhs_box_id = add_box!(diagram, rhs_box)
	# rhs_box_id = add_box!(diagram, WiringDiagram(expr.rhs, env))

	for i in ins(expr)
		src = findfirst( (x -> x==i).(ins(expr.lhs)) )
		if i in ins(expr.rhs)
			tgt = findfirst( (x -> x==i).(ins(expr.rhs)) )
			add_wire!(diagram, (input_id(diagram), src) => (rhs_box_id, tgt))
		else
			del_val = add_box!(diagram, mdisc(i))
			add_wire!(diagram, (input_id(diagram), src) => (del_val, 1))
		end
	end

	for i in outs(expr.rhs)
		src = findfirst( (x -> x==i).(outs(expr.rhs)) )
		tgt = findfirst( (x -> x==i).(outs(expr.lhs)) )
		add_wire!(diagram, (rhs_box_id, src) => (output_id(diagram), tgt))
	end

  output_env = merge(env, Dict( nameof(expr) => DiagramEntry(diagram)), rhs_env)
  return (diagram, output_env)
end

function lower(expr::SumExpr, env::MarkovEnv = MarkovEnv()) 
	diagram = WiringDiagram(ins(expr), outs(expr))
  body_box, body_env = lower(expr.body, env)
	box_val = add_box!(diagram, body_box)
	# box_val = add_box!(diagram, WiringDiagram(expr.body, env.symbol_table))

	for i in 1:length(ins(expr))
		add_wire!(diagram, (input_id(diagram), i) => (box_val, i))
	end

	for i in outs(expr.body)
		inner_loc = findfirst( (x -> x==i).(outs(expr.body)) )
		if i in outs(expr)
			outer_loc = findfirst( (x -> x==i).(outs(expr)) )
			add_wire!(diagram, (box_val, inner_loc) => (output_id(diagram), outer_loc) )
		else
			del_id = add_box!(diagram, mdisc(i))
			add_wire!(diagram, (box_val, inner_loc) => (del_id, 1) )
		end
	end

  return (diagram, merge(env, body_env))
end

function lower(expr::ProductExpr, env::MarkovEnv = MarkovEnv()) 
  
  # Copied from stackoverflow
  # ::Vector{(WiringDiagram, MarkovEnv)} -> (Vector{WiringDiagram}, Vector{MarkovEnv})
  unzip(a) = map(x->getfield.(a, x), fieldnames(eltype(a)))

  wd_env_pairs = [lower(f, env) for f in expr.factors]
  merged_factor_envs = merge([e for (wd, e) in wd_env_pairs]...)
	# factor_wds = [WiringDiagram(k, env.symbol_table) for k in expr.factors]
	#factor_wds = [md.wiring_diagram for md in factor_mds]
	boundary_diagram = WiringDiagram(ins(expr), outs(expr))
  factor_wds = [wd for (wd, e) in wd_env_pairs]
	box_vals = [add_box!(boundary_diagram, diagram) for diagram in factor_wds]

	box_val = Dict(zip(expr.factors, box_vals))

	all_ins = vcat([ins(factor) for factor in expr.factors]...)

	# wire the outputs
  # TODO: Clean up the nested for loops
	for factor in expr.factors
		for (idx, sym) in enumerate(outs(factor))
			out_location =	findfirst( (x -> x==sym).(outs(expr)) )
			num_syms = count( (x -> x==sym).(all_ins) )
			copy_val  = add_box!(boundary_diagram, mcopy(sym, num_syms+1))
			add_wire!(boundary_diagram, (box_val[factor], idx) => (copy_val, 1) )
			add_wire!(boundary_diagram, (copy_val, 1) => (output_id(boundary_diagram), out_location) )
			k = 2
			for in_factor in expr.factors
				if sym in ins(in_factor)
					input_index = findfirst( (x -> x==sym).(ins(in_factor)))
					add_wire!(boundary_diagram, (copy_val, k) => (box_val[in_factor], input_index))
					k = k+1
				end
			end
		end
	end

	for (input_index, input_sym) in enumerate(ins(expr))
		inner_input_locations = findall_inputs(input_sym, expr)
		num_copies = length(inner_input_locations)
		copy_val = add_box!(boundary_diagram, mcopy(input_sym, num_copies))
		add_wire!(boundary_diagram, (input_id(boundary_diagram), input_index) => (copy_val, 1) )
		k = 1
		for (box_expr, idx) in inner_input_locations
			add_wire!(boundary_diagram, (copy_val, k) => (box_val[box_expr], idx))
			k = k+1
		end
	end
  return (boundary_diagram, merge(env, merged_factor_envs))
end

function lower(exp::CondExpr, env::MarkovEnv = MarkovEnv())::(WiringDiagram, MarkovEnv)
    name = gensym("cond_"*string.(outs(exp))*"_given_"*string.(ins(exp)))
    boundary = Box(name, ins(exp), outs(exp))
    (inner_diagram, inner_env) = lower(exp.top, env)

    # This inner boundary serves to permute the outputs of the inner diagram
    # to target conditioning on the rightmost variables
    permuted_outs_left = outs(exp)
    permuted_outs_right = exp.vars
    permuted_outs = vcat(permuted_outs_left, permuted_outs_right)
    inner_boundary = WiringDiagram(ins(exp.top), permuted_outs)

    inner_diagram_id = add_box!(inner_boundary, inner_diagram)

    for (idx, sym) in enumerate(ins(exp.top))
        add_wire!(inner_boundary, (input_id(inner_boundary), idx) => (inner_diagram_id, idx))
    end

    for (idx, sym) in permuted_outs
        src = findfirst( (x -> x==sym).(outs(exp.top)) )
        add_wire!(inner_boundary, (inner_diagram_id, src) => (output_id(inner_boundary), idx))
    end

    entry = ConditionalEntry(boundary=boundary, inner_diagram=inner_boundary, cond_vars=exp.vars)
    new_env = merge(env, inner_env, Dict(name => entry))
    return (boundary, new_env)
end

mcopy(sym::Symbol, n::Int) = implicit_mcopy(Ports([sym]), n)
mcopy(sym::Symbol) = mcopy(sym, 2)
m_id(sym::Symbol)  = mcopy(sym, 1)
mdisc(sym::Symbol) = mcopy(sym, 0)
