module MarkovCats
using Base: show

export @vars, copykernel, discardkernel
export Port, Kernel, KernelList, PortGraph
export matching

include("dsl/types.jl")
include("dsl/constructors.jl")
include("dsl/printing.jl")
include("dsl/macros.jl")

include("graphmatching/matching.jl")
include("graphmatching/printing.jl")

end # module
