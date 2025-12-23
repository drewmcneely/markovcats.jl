module MarkovCats
using Base: show

# # Macros
# export @kernel, @kerneldef, @vars, @kernelassignments
# # IR Constructors
# export Var, Port, Kernel, KernelList, PortGraph, Signature
# export copykernel, discardkernel
# export AssignmentExpr, SumExpr, ProductExpr

# dsl/ exports
# parsedexpr/ exports
export parse_expr, ProductDependencyGraph, topological_sort
# kernels/ exports
# wiringdiagram/ exports
# graphmatching/ exports

# include("dsl/macros.jl")
# include("dsl/parsing.jl")

include("parsedexpr/types.jl")
include("parsedexpr/printing.jl")
include("parsedexpr/constructors.jl")
include("parsedexpr/helpers.jl")
include("parsedexpr/parsing.jl")

# include("kernels/types.jl")
# include("kernels/constructors.jl")
# include("kernels/helpers.jl")
# include("kernels/printing.jl")
# 
# include("wiringdiagram/types.jl")
# include("wiringdiagram/parsing.jl")
# include("wiringdiagram/printing.jl")
# 
# include("graphmatching/matching.jl")
# include("graphmatching/printing.jl")

end # module
