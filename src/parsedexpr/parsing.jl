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

""" Parse an Expr into an AssignmentExpr.

Grammar:
AssignmentExpr :	Kernel '=' SumExpr | ProductExpr

Examples:
Chapman-Kolmog. 	py(y) = sum(x)( f(y|x) * px(x) )
Graph State				pxy(x,y) = f(y|x) * px(x)
Independence			pxy(x,y) = px(x) * py(y)
"""
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
function is_assignment(ex::Expr)
	return ex.head == :(=)
end

""" Parse an Expr into a SumExpr
Grammar:
SumExpr : 'sum(' Symbols ')(' Body ')'
Symbols	: Symbol [',' Symbol]*
Body		: (ProductExpr | SumExpr | KernelExpr)

Examples:
Chapman-Kolmog.		sum(x)( f(y|x) * p(x) )
Marginalization		sum(x)( p(x,y) )

Expected Expr sum(Vars)(Body) is parsed
by Julia as a nested call:
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
function parse_sum(ex::Expr)::SumExpr
	vars = ex.args[1].args[2:end]
	unparsed_body = ex.args[2]
	return SumExpr(vars, parse_expr(unparsed_body))
end
function is_sum(ex::Expr)
	if (ex.head != :call) return false end
	if !(ex.args[1] isa Expr) return false end
	if (ex.args[1].head != :call) return false end
	return ex.args[1].args[1] == :sum
end

""" Parse an Expr into a ProductExpr
Grammar:
ProductExpr	: Kernel ('*' Kernel)+

Examples:
Graph state:	f(y|x) * p(x)
Independence:	px(x) * py(y)

A chain of multiplications will be parsed by
Julia as a single call to a multi-argument '*'
For instance, `dump(:( a*b*c ))` shows 
Expr
  head: Symbol call
  args: Array{Any}((4,))
    1: Symbol *
    2: Symbol a
    3: Symbol b
    4: Symbol c
"""
function parse_product(ex::Expr)::ProductExpr
	unparsed_factors = ex.args[2:end]
	parsed_factors = parse_expr.(unparsed_factors)
	return ProductExpr(parsed_factors)
end
function is_product(ex::Expr)
	return ex.args[1] == :*
end

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

""" Parse an Expr into a KernelExp
Grammar:
Kernel :			Name '(' Signature ')'
Signature:		Symbols | Conditional
Symbols:			Symbol (',' Symbol)+
Conditional:	Symbols '|' Symbols

Examples:
Univariate:			p(x)
Multivariate:		p(x,y)
Kernel:					f(y|x)
Multi Kernel:		f(x,y|a,b)

The Name(Symbols) case represents a kernel with no inputs
The Name(Conditional) case represents a kernel whose outputs
are on the left side of the pipe and inputs are on the right
"""
function parse_kernel(exp::Expr)::KernelExpr
	kname = exp.args[1]					# :f
	kerneltype = named
	sigexp = exp.args[2:end]		# [:x, :y, :z]

	# Case f(Vars)
	if all(x -> isa(x, Symbol), sigexp)
		return KernelExpr(kname, sigexp, Symbol[])

	# The following code is to parse the argument of a :call that looks like
	# f(x,y|a,b)
	# Since the pipe is parsed as the bitwise OR call, this means that the
	# argument expression will actually look like
	# [:x, [ :|, y, a ], b]
	# This code parses such an argument to convert it to
	# outputs = [:x, :y]
	# inputs  = [:a, :b]
	elseif has_one_A_rest_B(sigexp, Expr, Symbol)
		target = Symbol[]
		source = Symbol[]
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

		return KernelExpr(kname, target, source)
	else
		error("Unexpected syntax in signature body of kernel")
	end
end
