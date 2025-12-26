module MarkovCats
using Base: show

export markov_pipeline, plot, morphism, full_diagram

include("parsedexpr/types.jl")
include("parsedexpr/printing.jl")
include("parsedexpr/constructors.jl")
include("parsedexpr/helpers.jl")
include("parsedexpr/parsing.jl")

include("wiringdiagram/constructors.jl")
include("wiringdiagram/printing.jl")
include("wiringdiagram/theory.jl")

include("pipeline2.jl")

end # module
