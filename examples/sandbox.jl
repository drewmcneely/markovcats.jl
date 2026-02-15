using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using Catlab.WiringDiagramExpressions
using MarkovCats

# expr = :( j(z,a,x,b|c,d) = sum(y)( g(y,z|x,c) * f(x|c) * k(b|x,a,c) * h(a|y) ) )
expr = :( py(y) = sum(x)( f(y|x) * px(x) ))

cart_expr = to_cart_expr(expr)
# markov_expr = to_markov_expr(expr)
# println(markov_expr)
diagram = to_wiring_diagram(cart_expr)
markov_expr = to_hom_expr(FreeMarkovCategory, diagram)
println(markov_expr)

# plot(diagram, "test.png")
