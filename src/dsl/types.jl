# This is just a wrapper for symbols.
struct Var
	name::Symbol
end

"""
A signature is a pair of lists of Vars.
It represents the "w,x given y,z" portion of p(w,x|y,z)
"""
struct Signature
	target::Vector{Var}
	source::Vector{Var}
end

struct Kernel
	name::Symbol
	signature::Signature
end
inputs(k::Kernel) = k.signature.source
outputs(k::Kernel) = k.signature.target

