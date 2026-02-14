module MarkovCats
using Base: show

export markov_pipeline, plot, morphism, full_diagram
export to_wiring_diagram, to_cart_expr, to_markov_expr

include("parsedexpr/types.jl")
include("parsedexpr/printing.jl")
include("parsedexpr/constructors.jl")
include("parsedexpr/helpers.jl")
include("parsedexpr/parsing.jl")

include("wiringdiagram/constructors.jl")
include("wiringdiagram/printing.jl")
include("wiringdiagram/theory.jl")

include("pipeline.jl")

end # module
