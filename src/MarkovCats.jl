module MarkovCats
using Base: show

export @kernel, @kerneldef, @vars
export copykernel, discardkernel
export Port, Kernel, KernelList, PortGraph, Signature
export matching, parse_expr

include("dsl/types.jl")
include("dsl/constructors.jl")
include("dsl/printing.jl")
include("dsl/macros.jl")
include("dsl/parsing.jl")

include("graphmatching/matching.jl")
include("graphmatching/printing.jl")

end # module
