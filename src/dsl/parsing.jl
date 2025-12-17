# Many parts of this file are deprecated. Possibly the whole thing.

# TODO: Clean this up. Maybe make a second Expr type for the signature.
function parse_kernel_kerneltype(exp::Expr)::Kernel
	kname = exp.args[1]					# :f
	kerneltype = named
	sigexp = exp.args[2:end]		# [:x, :y, :z]

	if all(x -> isa(x, Symbol), sigexp)
		# The following was the old code when this function was a macro
		# return esc(:( Kernel($(QuoteNode(kname)), Signature([ $(sigexp...) ])) ))
		vars = [Var(x) for x in sigexp]

		return Kernel(kname, kerneltype, Signature(vars))
	elseif has_one_A_rest_B(sigexp, Expr, Symbol)
		target = Var[]
		source = Var[]
		call_index = findfirst( (x -> x isa Expr).(sigexp) )
		@assert sigexp[call_index].args[1] == :|
		pipe_left = sigexp[call_index].args[2]
		pipe_right = sigexp[call_index].args[3]
		@assert pipe_left isa Symbol
		@assert pipe_right isa Symbol

		for sym in sigexp[1:call_index-1]
			push!(target, Var(sym))
		end
		push!(target, Var(pipe_left))
		push!(source, Var(pipe_right))
		for sym in sigexp[call_index+1:end]
			push!(source, Var(sym))
		end

		# return esc(:( Kernel($(QuoteNode(kname)), [ $(target...) ] | [ $(source...) ] ) ))
		return Kernel(kname, kerneltype, target | source)
	else
		error("Unexpected syntax in signature body of kernel")
	end
end

"""
flatten() is a function that takes the RHS of a ParsedExpr
and flatttens it into a list of Kernels.
This is needed because sums, products, and kernels form nodes to the AST
but these each have equal class as morphisms in the matching algorithm.
"""
function flatten(ex::Kernel)::Vector{Kernel}
	return [ex]
end

function flatten(ex::SumExpr)::Vector{Kernel}
	return vcat([discardkernel(Var(v)) for v in ex.vars],
							flatten(ex.body))
end

function flatten(ex::ProductExpr)::Vector{Kernel}
	return vcat([flatten(factor) for factor in ex.factors]...)
end

function flatten(ex::AssignmentExpr)::KernelList
	return KernelList(ex.lhs, flatten(ex.rhs))
end

""" Count duplicate variables in a KernelList in order to generate copies.
Deprecated.
"""
function count_duplicates(kl::KernelList)::KernelList
	inner_kernels = copy(kl.inner_kernels)
	named_kernels = filter(k -> k.kerneltype == named, inner_kernels)
	ports = vcat([MarkovCats.ports(k) for k in named_kernels]...)
	vars = [p.var for p in ports]
	
	countvar(v::Var) = count( x -> x==v , vars )

	# copykernels = Kernel[]
	for v in unique(vars)
		numcopies = countvar(v) - 1
		# println("copy_", v, " * ", numcopies)
		push!(inner_kernels, repeat([copykernel(v)], numcopies)...)
	end

	return KernelList(kl.boundary_kernel, inner_kernels)
end
