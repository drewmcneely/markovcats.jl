module DSL
export @kerneldef , morphism_parsing_pipeline , pipenotation_to_morphisms , @vars , to_string

import Base: |

import Graphs
import GraphsMatching

# This is just a wrapper for symbols.
struct Var
	name::Symbol
end
Base.show(io::IO, v::Var) = print(io, v.name)

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
inputs(k::Kernel) = k.signature.source
outputs(k::Kernel) = k.signature.target

function copy(var::Var)
	name = Symbol(:copy_, var.name)
	sig = [var, var] | var
	Kernel(name, sig)
end

function discard(var::Var)
	name = Symbol(:discard_, var.name)
	sig = Var[] | var
	Kernel(name, sig)
end

sum(var::Var) = discard(var)

struct Port
	var::Var
	box::Symbol
end
input_ports(k::Kernel) = [Port(var, k.name) for var in inputs(k)]
output_ports(k::Kernel) = [Port(var, k.name) for var in outputs(k)]

function wires(ks::Vector{Kernel})
	inputs = vcat(input_ports.(ks))
	outputs = vcat(output_ports.(ks))
	function possible_match(output::Port, input::Port)
		(input.var == output.var) && !(input.box == output.box)
	end
	function possible_wires(output::Port, inputs::Vector{Port})
		[(output, input) for input in inputs if possible_match(output, input)]
	end
	vcat((o -> possible_wires(o, inputs)).(outputs))
end

macro kerneldef(exp)
	@assert exp.head == :(=) 
	lhs, rhs = exp.args
	@assert lhs.head == :call #Left side must look like f(y|x)
	fname = lhs.args[1]
	outer_signature = lhs.args[2]
	#return :(morphism_parsing_pipeline($(QuoteNode(fname)), $(esc(outer_signature)), $(Expr(:quote, rhs))))
	return 
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

@vars x y z
g = Kernel(:g, (z | y));
f = Kernel(:f, (y | x));
test_morphisms = [f, g, copy(y), discard(y)]


end # module
