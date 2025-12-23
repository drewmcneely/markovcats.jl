# TODO: Implement the following overall structure
# So here's my idea. We currently 
#
# TODO: Make type ProductDiagram in wiringdiagrams/?
# It's basically a list of kernels with edges that connect ports.
# constructor ProductDiagram(::Vector{NamedKernel})
# wire every output port to CopyKernel(var(port), count(matching_input_kernels))
# wire the first output of the copy to the boundary output
# wire the rest of the copy outputs to the matching inputs
# then do the same for dangling inputs:
# find the matching dangling inputs, and wire them to a copy with a count of that match. Then wire the input of that copy to the boundary input.
#
# Then pass that to MarkovCats.WiringDiagram
#
#
struct StateSpace
	name::Symbol
end

# TODO: Implement a StateSpace/Category Object type and give Vars a field of that type
""" Represents a variable in a kernel expression
"""
struct Var
	name::Symbol
	# statespace::Union{Nothing, StateSpace} = nothing
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

@enum PortDirection input output
Base.@kwdef mutable struct Port
	var::Var
	kernel::Union{Nothing, Kernel} = nothing
	direction::PortDirection
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

struct CopyKernel <: Kernel
	var::Var
end

struct DiscardKernel <: Kernel
	var::Var
end

# TODO: KernelList with an LHS and RHS is likely not needed anymore. Reuse as a single list? Or should I just work with Vector{Kernel}s?
struct KernelList
	boundary_kernel::Kernel
	inner_kernels::Vector{Kernel}
end
