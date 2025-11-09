# Signature constructors
import Base: |
|(t::Vector{Var}, s::Vector{Var}) = Signature(t,s)
|(t::Var, s::Var)                 = [t] | [s]
|(t::Vector{Var}, s::Var)         =  t  | [s]
|(t::Var, s::Vector{Var})         = [t] |  s
Signature(t)                      =  t  | [ ]

# Kernel constructors

"""
This kernel takes a name and a signature.
It constructs the ports, which reference the kernel they're a part of, and then constructs the kernel.
"""
function Kernel(name::Symbol, signature::Signature)
	inputvars = signature.source
	inputports = [Port(var=v, kernel=nothing, kind=:input, index=i) for (i,v) in enumerate(inputvars)]
	outputvars = signature.target
	outputports = [Port(var=v, kernel=nothing, kind=:output, index=i) for (i,v) in enumerate(outputvars)]

	k = Kernel(name, inputports, outputports)
	for p in vcat(inputports, outputports)
		p.kernel = k
	end
	return k
end

function copykernel(var::Var)
	name = Symbol(:copy_, var.name)
	sig = [var, var] | var
	Kernel(name, sig)
end

function discardkernel(var::Var)
	name = Symbol(:discard_, var.name)
	sig = Var[] | var
	Kernel(name, sig)
end

# sum(var::Var) = discard(var)
# sum = discard
