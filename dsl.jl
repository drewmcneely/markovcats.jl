module Sandbox
export @kerneldef
export morphism_parsing_pipeline
export pipenotation_to_morphisms
export @vars
export to_string

import Base: |

# This is just a wrapper for symbols.
struct Var
	name::Symbol
end
Base.show(io::IO, v::Var) = print(io, v.name)

"""
A signature is a pair of lists of Vars.
It represents the "w,x given y,z" portion of p(w,x|y,z)
"""
struct Signature
	target::Vector{Var}
	source::Vector{Var}
end
function to_string(v::Vector{Var})
	names = [String(n.name) for n in v]
	return join(names, ",")
end
function Base.show(io::IO, sig::Signature)
	target = to_string(sig.target)
	source = to_string(sig.source)
	print(io, string("( ", target, " | ", source, " )"))
end

# Constructors and overloading the | operator
|(t::Vector{Var}, s::Vector{Var}) = Signature(t,s)
|(t::Var, s::Var)                 = [t] | [s]
|(t::Vector{Var}, s::Var)         =  t  | [s]
|(t::Var, s::Vector{Var})         = [t] |  s
Signature(t)                      =  t  | [ ]

struct Kernel
	name::Symbol
	signature::Signature
end

function copy(var::Var)
	name = Symbol(:copy_, var.name)
	sig = [var, var] | var
	Kernel(name, sig)
end
sum(var::Var) = sum(var.name)

function discard(var::Var)
	name = Symbol(:discard_, var.name)
	sig = [] | var
	Kernel(name, sig)
end

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

macro kerneldef(exp)
	@assert exp.head == :(=) 
	lhs, rhs = exp.args
	@assert lhs.head == :call #Left side must look like f(y|x)
	#fname = lhs.args[1]
	#outer_signature = lhs.args[2]
	#return :(morphism_parsing_pipeline($(QuoteNode(fname)), $(esc(outer_signature)), $(Expr(:quote, rhs))))
	dump(lhs)
	dump(rhs)
	return
	#return :(morphism_parsing_pipeline($(Expr(:quote, lhs)), $Expr(:quote, rhs)))
end

"""
function morphism_parsing_pipeline(outer_name::Symbol, outer_signature::Signature, rhs::Expr)
	print("This is the outer_name\n")
	dump(outer_name)
	print("\nThis is the outer_signature\n")
	print(outer_signature)
	print("\nThis is the rhs\n")
	dump(rhs)
end
"""
function morphism_parsing_pipeline(lhs, rhs)
	dump(lhs)
	dump(rhs)
end

function pipenotation_to_morphisms(expr::Expr)
	print(expr)
end


end # module
