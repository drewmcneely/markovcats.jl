# TODO: Implement a StateSpace/Category Object type and give Vars a field of that type
""" Represents a variable in a kernel expression
"""
struct Var
	name::Symbol
end

"""
A signature is a pair of lists of Vars.
It represents the "w,x given y,z" portion of p(w,x|y,z)
This may be obsolete
"""
struct Signature
	target::Vector{Var}
	source::Vector{Var}
end

abstract type Kernel end

Base.@kwdef mutable struct Port
	var::Var
	kernel::Union{Nothing, Kernel} = nothing
	kind::Symbol	# :input or :output
	index::Int
end

# TODO: Refactor KernelTypes into subtypes of Kernel. Convert any methods that utilize KernelType into dispatch
@enum KernelType named counit comultiplication

struct NamedKernel <: Kernel
	name::Symbol
	kerneltype::KernelType
	inputports::Vector{Port}
	outputports::Vector{Port}
end
ports(k::NamedKernel) = vcat(k.inputports, k.outputports)
signature(k::NamedKernel) = [p.var for p in k.inputports] | [p.var for p in k.outputports]
inputports(ks::AbstractVector{<:Kernel}) = vcat((k -> k.inputports).(ks)...)
inputports(k::Kernel) = inputports([k])
outputports(ks::AbstractVector{<:Kernel}) = vcat((k -> k.outputports).(ks)...)
outputports(k::Kernel) = outputports([k])

struct DiscardKernel <: Kernel
	var::Var
end

struct KernelList
	boundary_kernel::Kernel
	inner_kernels::Vector{Kernel}
end

