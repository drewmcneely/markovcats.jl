module MarkovCats
using Base: show

export @kernel, @kerneldef, @vars
export copykernel, discardkernel
export Port, Kernel, KernelList, PortGraph, Signature
export matching

include("dsl/types.jl")
include("dsl/constructors.jl")
include("dsl/printing.jl")
include("dsl/macros.jl")

include("graphmatching/matching.jl")
include("graphmatching/printing.jl")

end # module
