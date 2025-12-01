function parse_expr(ex::Expr)::ParsedExpr
	if ex |> is_assignment
		return parse_assignment(ex)
	elseif ex |> is_sum
		return parse_sum(ex)
	elseif ex |> is_product
		return parse_product(ex)
	elseif ex |> is_kernel
		return parse_kernel(ex)
	else
		error("The following expression did not match any defined cases\n",
					ex,
					)
	end
end

function is_assignment(ex::Expr)
	return ex.head == :(=)
end
function parse_assignment(ex::Expr)::AssignmentExpr
	lhs = parse_kernel(ex.args[1])
	unparsed_rhs = ex.args[2]
	if unparsed_rhs isa Expr && unparsed_rhs.head == :block
		non_line_nodes = filter(x -> !(x isa LineNumberNode), unparsed_rhs.args)
		@assert length(non_line_nodes) == 1 # "Expected single expression in RHS"
		unparsed_rhs = non_line_nodes[1]
	end
	parsed_rhs = parse_expr(unparsed_rhs)
	return AssignmentExpr(lhs, parsed_rhs)
end

"""
Notation looks like
sum(Vars)( Body )
This means its a "curried" call
Expr
  head: Symbol call
  args: Array{Any}((2,))
    1: Expr
      head: Symbol call
      args: Array{Any}((2,))
        1: Symbol sum
        2: Symbol Vars
    2: Symbol Body
"""
function is_sum(ex::Expr)
	if (ex.head != :call) return false end
	if !(ex.args[1] isa Expr) return false end
	if (ex.args[1].head != :call) return false end
	return ex.args[1].args[1] == :sum
end
function parse_sum(ex::Expr)::SumExpr
	vars = ex.args[1].args[2:end]
	unparsed_body = ex.args[2]
	return SumExpr(vars, parse_expr(unparsed_body))
end

"""
dump(:( a*b*c ))
Expr
  head: Symbol call
  args: Array{Any}((4,))
    1: Symbol *
    2: Symbol a
    3: Symbol b
    4: Symbol c
"""
function is_product(ex::Expr)
	return ex.args[1] == :*
end
function parse_product(ex::Expr)::ProductExpr
	unparsed_factors = ex.args[2:end]
	parsed_factors = parse_expr.(unparsed_factors)
	return ProductExpr(parsed_factors)
end

"""
Kernel expressions have 2 main forms:
The first form looks like f(x,y)
This represents a state whose outputs are x and y, and has no inputs.
The second form looks like f(x,y|a,b)
This represents a kernel whose inputs are [a,b] and outputs are [x,y]
We do a bit of pattern matching just to simplify the syntax on the user end
so that one can write f(x,y|a,b)
instead of f( [x,y] | [a,b] ) or f( (x,y) | (a,b) )
"""
function is_kernel(ex::Expr)
	return ex.head == :call
end

# This returns true if v has one element of type A and all other elements have type B
function has_one_A_rest_B(v::AbstractVector{Any}, ::Type{A}, ::Type{B}) where {A,B}
	nA = 0
	for x in v
		if x isa A
			nA += 1
		elseif !(x isa B)
			return false
		end
	end
	return nA == 1
end

# TODO: Clean this up. Maybe make a second Expr type for the signature.
function parse_kernel(exp::Expr)::Kernel
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
