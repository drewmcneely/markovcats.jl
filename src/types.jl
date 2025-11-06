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

# Constructors and overloading the | operator
|(t::Vector{Var}, s::Vector{Var}) = Signature(t,s)
|(t::Var, s::Var)                 = [t] | [s]
|(t::Vector{Var}, s::Var)         =  t  | [s]
|(t::Var, s::Vector{Var})         = [t] |  s
Signature(t)                      =  t  | [ ]

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

struct Kernel
	name::Symbol
	signature::Signature
end
inputs(k::Kernel) = k.signature.source
outputs(k::Kernel) = k.signature.target

struct Port
	var::Var
	box::Symbol
end
input_ports(k::Kernel) = [Port(var, k.name) for var in inputs(k)]
output_ports(k::Kernel) = [Port(var, k.name) for var in outputs(k)]

