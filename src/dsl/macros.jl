"""
Macro that lets you define variables. 
Usage: @vars x y z
Turns into:
x = Var(:x)
y = Var(:y)
z = Var(:z)
"""
macro vars(names...)
	assigns = [:( $(esc(n)) = Var($(QuoteNode(n)))) for n in names]
	Expr(:block, assigns...)
end

macro kernel(exp)
	@assert exp.head == :call		# exp is f(x,y,z)
	kname = exp.args[1]					# :f
	sigexp = exp.args[2:end]		# [:x, :y, :z]

	#varsexp = :(@vars $(sigexp...) )

	if all(x -> isa(x, Symbol), sigexp)
		return esc(:( Kernel($(QuoteNode(kname)), Signature([ $(sigexp...) ])) ))
	elseif has_one_A_rest_B(sigexp, Expr, Symbol)
		#error("This syntax is not yet implemented")
		target = Symbol[]
		source = Symbol[]
		call_index = findfirst( (x -> x isa Expr).(sigexp) )
		@assert sigexp[call_index].args[1] == :|
		pipe_left = sigexp[call_index].args[2]
		pipe_right = sigexp[call_index].args[3]
		@assert pipe_left isa Symbol
		@assert pipe_right isa Symbol

		for sym in sigexp[1:call_index-1]
			push!(target, sym)
		end
		push!(target, pipe_left)
		push!(source, pipe_right)
		for sym in sigexp[call_index+1:end]
			push!(source, sym)
		end

		return esc(:( Kernel($(QuoteNode(kname)), [ $(target...) ] | [ $(source...) ] ) ))
	else
		error("Unexpected syntax in signature body of kernel")
	end

	#return esc(Expr(:block, varsexp, kernelexp))

	# return esc(quote
	# 					 # call existing @vars on terms
	# 					 @vars $(sigexp...)

	# 					 # define f = Kernel(:f, Signature([x, y, z]))
	# 					 $(kname) = Kernel($(QuoteNode(kname)), Signature([ $(sigexp...) ]))
	# 				 end)

end

macro kerneldef(exp)
	@assert exp.head == :call		# exp is f(x,y,z)
	kname = exp.args[1]					# :f
	sigexp = exp.args[2:end]		# [:x, :y, :z]

	#varsexp = :(@vars $(sigexp...) )

	if all(x -> isa(x, Symbol), sigexp)
		return esc(:( $(kname) = Kernel($(QuoteNode(kname)), Signature([ $(sigexp...) ])) ))
	elseif has_one_A_rest_B(sigexp, Expr, Symbol)
		#error("This syntax is not yet implemented")
		target = Symbol[]
		source = Symbol[]
		call_index = findfirst( (x -> x isa Expr).(sigexp) )
		@assert sigexp[call_index].args[1] == :|
		pipe_left = sigexp[call_index].args[2]
		pipe_right = sigexp[call_index].args[3]
		@assert pipe_left isa Symbol
		@assert pipe_right isa Symbol

		for sym in sigexp[1:call_index-1]
			push!(target, sym)
		end
		push!(target, pipe_left)
		push!(source, pipe_right)
		for sym in sigexp[call_index+1:end]
			push!(source, sym)
		end

		return esc(:( $(kname) = Kernel($(QuoteNode(kname)), [ $(target...) ] | [ $(source...) ] ) ))
	else
		error("Unexpected syntax in signature body of kernel")
	end

	#return esc(Expr(:block, varsexp, kernelexp))

	# return esc(quote
	# 					 # call existing @vars on terms
	# 					 @vars $(sigexp...)

	# 					 # define f = Kernel(:f, Signature([x, y, z]))
	# 					 $(kname) = Kernel($(QuoteNode(kname)), Signature([ $(sigexp...) ]))
	# 				 end)

end

macro kerneleq(exp)
	@assert exp.head == :(=) 
	lhs, rhs = exp.args
	@assert lhs.head == :call #Left side must look like f(y|x)
	fname = lhs.args[1]
	outer_signature = lhs.args[2]
	#return :(morphism_parsing_pipeline($(QuoteNode(fname)), $(esc(outer_signature)), $(Expr(:quote, rhs))))
	return 
end

"""
The following is the proper pipeline order from an exp to a PortGraph
exp :: Expr |> parse_expr					:: ParsedExpr
						|> flatten						:: KernelList
						|> count_duplicates		:: KernelList
						|> PortGraph					:: PortGraph
						|> matching						:: PortGraph
						|> MarkovCats.plot		:: Nothing
"""
# vvv COMMENTED OUT BY CLAUDE (references undefined types KernelList, PortGraph) vvv
# macro kernelassignments(block)
#     # Validate it's a begin block
#     @assert block.head == :block
#
#     kernel_assignments = filter(x -> !(x isa LineNumberNode), block.args)
#
#     kls = [pipeline_kl(ex) for ex in kernel_assignments]
# 		pgs = [pipeline_pg(kl) for kl in kls]
# 		names = [kl.boundary_kernel.name for kl in kls]
#
# 		pg_assignments = [:( $(esc(name)) = $(pg) ) for (name, pg) in zip(names, pgs)]
# 		Expr(:block, pg_assignments...)
# end
#
# function pipeline_kl(ex::Expr)::KernelList
# 	return ex |> parse_expr |> flatten |> count_duplicates
# end
# function pipeline_pg(kl::KernelList)::PortGraph
# 	return kl |> PortGraph |> matching
# end
# ^^^ COMMENTED OUT BY CLAUDE ^^^

# vvv ADDED BY CLAUDE vvv
"""
    @markov_program ObType HomType begin
        px = 𝓝([1, 2], [1 1; 1 2])
        f  = GaussianKernel([2 0; 0 2], [2, 3], [4 5; 5 6])
        @pipe begin
            py(y) = sum(x)( f(y|x) * px(x) )
        end
    end

Macro that compiles a Markov program into a concrete morphism.
Assignments define concrete kernels (generators). The `@pipe` block
contains the pipe notation expression. The result is assigned to
the output variable name from the pipe notation LHS (e.g. `py`).
"""
macro markov_program(ob_type, hom_type, block)
	@assert block.head == :block

	stmts = filter(x -> !(x isa LineNumberNode), block.args)

	assignments = Expr[]
	pipe_expr = nothing
	gen_names = Symbol[]

	for stmt in stmts
		if stmt isa Expr && stmt.head == :(=) && stmt.args[1] isa Symbol
			push!(assignments, stmt)
			push!(gen_names, stmt.args[1])
		elseif stmt isa Expr && stmt.head == :macrocall && stmt.args[1] == Symbol("@pipe")
			inner_block = stmt.args[end]
			inner_stmts = filter(x -> !(x isa LineNumberNode), inner_block.args)
			@assert length(inner_stmts) == 1 "Expected exactly one expression in @pipe block"
			pipe_expr = inner_stmts[1]
		else
			error("Unexpected expression in @markov_program block")
		end
	end

	@assert pipe_expr !== nothing "@markov_program requires a @pipe block"
	@assert pipe_expr.head == :(=) "Pipe expression must be an assignment"
	output_name = pipe_expr.args[1].args[1]

	assignment_exprs = [esc(a) for a in assignments]
	gen_map_pairs = [:($(QuoteNode(n)) => $(esc(n))) for n in gen_names]
	quoted_pipe = QuoteNode(pipe_expr)

	quote
		$(assignment_exprs...)
		$(esc(output_name)) = evaluate_markov_program(
			$(esc(ob_type)), $(esc(hom_type)),
			$(quoted_pipe),
			Dict($(gen_map_pairs...))
		)
	end
end
# ^^^ ADDED BY CLAUDE ^^^
