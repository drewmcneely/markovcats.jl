module MarkovCats
using Base: show

export markov_pipeline, plot, morphism, full_diagram
export to_wiring_diagram, to_cart_expr, to_markov_expr, run_markov_program
export FreeMarkovCategory

export GaussStateSpace, GaussianKernel
export 𝓝, Gaussian, state, affine, linear

include("parsedexpr/types.jl")
include("parsedexpr/printing.jl")
include("parsedexpr/parsing.jl")

include("wiringdiagram/constructors.jl")
include("wiringdiagram/printing.jl")

include("categories/theory.jl")
include("categories/gauss.jl")

include("pipeline.jl")
include("dsl/macros.jl")

end # module
