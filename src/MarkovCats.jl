# Main entry point for the library. Mostly includes and exports.
module MarkovCats
using Base: show

export @vars, copykernel, discardkernel, possiblewiring, Wiring, vertices
export Port, Kernel, KernelList, PortGraph

include("dsl/types.jl")
include("dsl/constructors.jl")
include("dsl/printing.jl")
include("dsl/macros.jl")

include("graphmatching/matching.jl")
include("graphmatching/printing.jl")

end # module
