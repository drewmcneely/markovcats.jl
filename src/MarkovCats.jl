module MarkovCats
using Base: show

export plot
export parse_expr, to_wiring_diagram, run_markov_program, to_homexpr_env
export FreeMarkovCategory

export GaussStateSpace, GaussianKernel
export 𝓝, Gaussian, state, affine, linear

include("types.jl")

include("parsedexpr/types.jl")
include("parsedexpr/printing.jl")
include("parsedexpr/constructors.jl")
include("parsedexpr/helpers.jl")
include("parsedexpr/parsing.jl")

include("wiringdiagram/types.jl")
include("wiringdiagram/parsing.jl")
include("wiringdiagram/printing.jl")

include("homexpr/theory.jl")
include("homexpr/types.jl")
include("homexpr/constructors.jl")
include("homexpr/helpers.jl")
include("homexpr/parsing.jl")
include("homexpr/printing.jl")

include("categories/gauss.jl")

include("pipeline.jl")
include("dsl/macros.jl")

end # module
