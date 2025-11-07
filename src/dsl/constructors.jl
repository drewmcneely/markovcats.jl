# Signature constructors
import Base: |
|(t::Vector{Var}, s::Vector{Var}) = Signature(t,s)
|(t::Var, s::Var)                 = [t] | [s]
|(t::Vector{Var}, s::Var)         =  t  | [s]
|(t::Var, s::Vector{Var})         = [t] |  s
Signature(t)                      =  t  | [ ]

# Kernel constructors
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

#sum(var::Var) = discard(var)
sum = discard
