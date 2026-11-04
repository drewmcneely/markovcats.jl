module MarkovCats
using Base: show

export plot
export to_wiring_diagram, run_markov_program
export FreeMarkovCategory

export GaussStateSpace, GaussianKernel
export 𝓝, Gaussian, state, affine, linear

include("parsedexpr/types.jl")
include("parsedexpr/printing.jl")
include("parsedexpr/constructors.jl")
include("parsedexpr/helpers.jl")
include("parsedexpr/parsing.jl")

include("wiringdiagram/constructors.jl")
include("wiringdiagram/printing.jl")

include("categories/theory.jl")
include("categories/gauss.jl")

include("pipeline.jl")
include("dsl/macros.jl")

end # module
