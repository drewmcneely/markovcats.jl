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

abstract type AbstractPort end
abstract type AbstractKernel end

struct Kernel <: AbstractKernel
	name::Symbol
	inputports::Vector{AbstractPort}
	outputports::Vector{AbstractPort}
end
ports(k::Kernel) = vcat(k.inputports, k.outputports)
signature(k::Kernel) = [p.var for p in k.inputports] | [p.var for p in k.outputports]
inputports(ks::AbstractVector{<:AbstractKernel}) = vcat((k -> k.inputports).(ks)...)
outputports(ks::AbstractVector{<:AbstractKernel}) = vcat((k -> k.outputports).(ks)...)

# TODO: Add show method for ports. Make it contain info on what kernel it's attached to and its var
Base.@kwdef mutable struct Port <: AbstractPort
	var::Var
	kernel::Union{Nothing, Kernel} = nothing
	kind::Symbol	# :input or :output
	index::Int
end

struct KernelList
	boundary_kernel::Kernel
	inner_kernels::Vector{Kernel}
end
