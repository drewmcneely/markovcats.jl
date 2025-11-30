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

