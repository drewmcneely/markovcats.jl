# Main entry point for the library. Mostly includes and exports.
module MarkovCats
using Base: show

export @vars, Kernel, copykernel, discardkernel, possiblewiring, plot, Wiring, vertices

include("dsl/types.jl")
include("dsl/constructors.jl")
include("dsl/printing.jl")
include("dsl/macros.jl")

include("graphmatching/matching.jl")

end # module
