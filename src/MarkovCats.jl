module MarkovCats
using Base: show

# Macros
export @kernel, @kerneldef, @vars, @kernelassignments
# IR Constructors
export Var, Port, Kernel, KernelList, PortGraph, Signature
export copykernel, discardkernel
export AssignmentExpr, SumExpr, ProductExpr
# Pipeline components
export parse_expr, flatten, count_duplicates, matching
export plot, equivalent_portgraphs, portgraph_signature

include("dsl/types.jl")
include("dsl/constructors.jl")
include("dsl/printing.jl")
include("dsl/macros.jl")
include("dsl/parsing.jl")

include("graphmatching/matching.jl")
include("graphmatching/printing.jl")

end # module
