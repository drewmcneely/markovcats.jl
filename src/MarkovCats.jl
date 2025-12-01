module MarkovCats
using Base: show

export @kernel, @kerneldef, @vars
export copykernel, discardkernel
export Port, Kernel, KernelList, PortGraph, Signature
export matching, parse_expr, flatten, count_duplicates

include("dsl/types.jl")
include("dsl/constructors.jl")
include("dsl/printing.jl")
include("dsl/macros.jl")
include("dsl/parsing.jl")

include("graphmatching/matching.jl")
include("graphmatching/printing.jl")


"""
The following is the proper pipeline order from an exp to a PortGraph
exp :: Expr |> parse_expr					:: ParsedExpr
						|> flatten						:: KernelList
						|> count_duplicates		:: KernelList
						|> PortGraph					:: PortGraph
						|> matching						:: PortGraph
						|> MarkovCats.plot		:: Nothing
"""

end # module
