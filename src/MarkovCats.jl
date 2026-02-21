module MarkovCats
using Base: show

export markov_pipeline, plot, morphism, full_diagram
export to_wiring_diagram, to_cart_expr, to_markov_expr
export FreeMarkovCategory

# vvv MODIFIED BY CLAUDE vvv
export GaussStateSpace, GaussianKernel, hom_to_obs
export 𝓝, Gaussian, state, affine, linear
export @markov_program, evaluate_markov_program
# ^^^ MODIFIED BY CLAUDE ^^^

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
# vvv ADDED BY CLAUDE vvv
include("dsl/macros.jl")
# ^^^ ADDED BY CLAUDE ^^^

end # module
