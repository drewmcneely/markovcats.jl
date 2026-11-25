using Catlab.WiringDiagrams.DirectedWiringDiagrams
using Catlab.WiringDiagrams.MonoidalDirectedWiringDiagrams

function Base.convert(::Type{WiringDiagram}, box::Box)
    diagram = WiringDiagram(box.input_ports, box.output_ports)
    box_id = add_box!(diagram, box)
    for (idx, sym) in enumerate(box.input_ports)
        add_wire!(diagram, (input_id(diagram), idx) => (box_id, idx))
    end
    for (idx, sym) in enumerate(box.output_ports)
        add_wire!(diagram, (box_id, idx) => (output_id(diagram), idx))
    end
    return diagram
end

function MarkovEnv{WiringDiagram}(expr::BlockExpr)
    env = MarkovEnv{WiringDiagram}(Dict{Symbol, EnvEntry{WiringDiagram}}())
    for assignment in expr.statements
        diagram, env = lower(assignment, env)
    end
    return env
end

findport(p::Symbol, ps::Vector{Symbol}) = findfirst( (x -> x==p).(ps) )

# Example
# prior(x1) = ∑(x0)( former(x1 | x0) )
# joint(x1, y1) = prior(x1) * model(y1 | x1)

function lower(expr::KernelExpr, env::MarkovEnv{WiringDiagram} = MarkovEnv{WiringDiagram}())::Tuple{WiringDiagram, MarkovEnv{WiringDiagram}}
    if haskey(env, expr.name)
        return (env[expr.name].morphism, env)
    else
        # diagram = WiringDiagram(ins(expr), outs(expr))
        # box_id = add_box!(diagram, Box(expr.name, expr.inputs, expr.outputs))
        # for (idx, sym) in enumerate(ins(expr))
        #     add_wire!(diagram, (input_id(diagram), idx) => (box_id, idx))
        # end
        # for (idx, sym) in enumerate(outs(expr))
        #     add_wire!(diagram, (box_id, idx) => (output_id(diagram), idx))
        # end
        return (Box(expr.name, expr.inputs, expr.outputs), env)
    end
end

function lower(expr::AssignmentExpr, env::MarkovEnv{WiringDiagram} = MarkovEnv{WiringDiagram}())::Tuple{WiringDiagram, MarkovEnv{WiringDiagram}}
  # FIXME: This code does not check environment for the LHS, and does not update environment
  # if the LHS has an overwrite. As written, I expect overwrites to just not happen.
	diagram = WiringDiagram(ins(expr), outs(expr))
  rhs_box, rhs_env = lower(expr.rhs, env)
	rhs_box_id = add_box!(diagram, rhs_box)

	for i in ins(expr)
		src = findport(i, ins(expr.lhs) )
		if i in ins(expr.rhs)
			tgt = findport(i, (ins(expr.rhs)) )
			add_wire!(diagram, (input_id(diagram), src) => (rhs_box_id, tgt))
		else
			del_val = add_box!(diagram, mdisc(i))
			add_wire!(diagram, (input_id(diagram), src) => (del_val, 1))
		end
	end

	for i in outs(expr.rhs)
		src = findport(i, (outs(expr.rhs)) )
		tgt = findport(i, (outs(expr.lhs)) )
		add_wire!(diagram, (rhs_box_id, src) => (output_id(diagram), tgt))
	end

  output_env = merge(env, MarkovEnv{WiringDiagram}( Dict(nameof(expr) => HomEntry{WiringDiagram}(diagram))), rhs_env)
  return (diagram, output_env)
end

function lower(expr::SumExpr, env::MarkovEnv{WiringDiagram} = MarkovEnv{WiringDiagram}())::Tuple{WiringDiagram, MarkovEnv{WiringDiagram}}
	diagram = WiringDiagram(ins(expr), outs(expr))
  body_box, body_env = lower(expr.body, env)
	box_val = add_box!(diagram, body_box)

	for i in 1:length(ins(expr))
		add_wire!(diagram, (input_id(diagram), i) => (box_val, i))
	end

	for i in outs(expr.body)
		inner_loc = findport(i, (outs(expr.body)) )
		if i in outs(expr)
			outer_loc = findport(i, (outs(expr)) )
			add_wire!(diagram, (box_val, inner_loc) => (output_id(diagram), outer_loc) )
		else
			del_id = add_box!(diagram, mdisc(i))
			add_wire!(diagram, (box_val, inner_loc) => (del_id, 1) )
		end
	end

  return (diagram, merge(env, body_env))
end

function lower(expr::ProductExpr, env::MarkovEnv{WiringDiagram} = MarkovEnv{WiringDiagram}())::Tuple{WiringDiagram, MarkovEnv{WiringDiagram}}
  wd_env_pairs = [lower(f, env) for f in expr.factors]
  merged_factor_envs = merge([e for (wd, e) in wd_env_pairs]...)
	boundary_diagram = WiringDiagram(ins(expr), outs(expr))
  factor_wds = [wd for (wd, e) in wd_env_pairs]
	box_vals = [add_box!(boundary_diagram, diagram) for diagram in factor_wds]

	box_val = Dict(zip(expr.factors, box_vals))

	all_ins = vcat([ins(factor) for factor in expr.factors]...)

	# wire the outputs
  # TODO: Clean up the nested for loops
	for factor in expr.factors
		for (idx, sym) in enumerate(outs(factor))
			out_location =	findport(sym, (outs(expr)) )
			num_syms = count( (x -> x==sym).(all_ins) )
			copy_val  = add_box!(boundary_diagram, mcopy(sym, num_syms+1))
			add_wire!(boundary_diagram, (box_val[factor], idx) => (copy_val, 1) )
			add_wire!(boundary_diagram, (copy_val, 1) => (output_id(boundary_diagram), out_location) )
			k = 2
			for in_factor in expr.factors
				if sym in ins(in_factor)
					input_index = findport(sym, (ins(in_factor)))
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

function lower(exp::CondExpr, env::MarkovEnv{WiringDiagram} = MarkovEnv{WiringDiagram}())::Tuple{WiringDiagram, MarkovEnv{WiringDiagram}}
    name = gensym(string("cond_",string.(outs(exp)),"_given_",string.(ins(exp))))
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

    for (idx, sym) in enumerate(permuted_outs)
        src = findport(sym, (outs(exp.top)) )
        add_wire!(inner_boundary, (inner_diagram_id, src) => (output_id(inner_boundary), idx))
    end

    entry = CondEntry{WiringDiagram}(boundary=boundary,
                                     innards=inner_boundary,
                                     cond_vars=exp.vars,
                                     input_vars=ins(exp.top),
                                     output_vars=outs(exp))
    new_env = merge(env, inner_env, MarkovEnv{WiringDiagram}(Dict(name => entry)))
    return (boundary, new_env)
end

mcopy(sym::Symbol, n::Int) = implicit_mcopy(Ports([sym]), n)
mcopy(sym::Symbol) = mcopy(sym, 2)
m_id(sym::Symbol)  = mcopy(sym, 1)
mdisc(sym::Symbol) = mcopy(sym, 0)
