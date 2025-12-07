# Signature constructors
import Base: |
|(t::Vector{Var}, s::Vector{Var}) = Signature(t,s)
|(t::Var, s::Var)                 = [t] | [s]
|(t::Vector{Var}, s::Var)         =  t  | [s]
|(t::Var, s::Vector{Var})         = [t] |  s
Signature(t)                      =  t  | Var[]

# Kernel constructors

"""
This kernel takes a name and a signature.
It constructs the ports, which reference the kernel they're a part of, and then constructs the kernel.
"""
function Kernel(name::Symbol, kerneltype::KernelType, signature::Signature)
	inputvars = signature.source
	inputports = [Port(var=v, kernel=nothing, kind=:input, index=i) for (i,v) in enumerate(inputvars)]
	outputvars = signature.target
	outputports = [Port(var=v, kernel=nothing, kind=:output, index=i) for (i,v) in enumerate(outputvars)]

	k = Kernel(name, kerneltype, inputports, outputports)
	for p in vcat(inputports, outputports)
		p.kernel = k
	end
	return k
end

Kernel(name::Symbol, signature::Signature) = Kernel(name, named, signature)

function copykernel(var::Var)
	name = Symbol(:copy_, var.name)
	kerneltype = comultiplication
	sig = [var, var] | var
	Kernel(name, kerneltype, sig)
end

function discardkernel(var::Var)
	name = Symbol(:discard_, var.name)
	kerneltype = counit
	sig = Var[] | var
	Kernel(name, kerneltype, sig)
end

