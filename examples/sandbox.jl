# using Pkg
# Pkg.activate(joinpath(@__DIR__, ".."))

using Catlab.WiringDiagramExpressions
using MarkovCats

# expr = :( j(z,a,x,b|c,d) = sum(y)( g(y,z|x,c) * f(x|c) * k(b|x,a,c) * h(a|y) ) )
expr = :(f(y,x) = p(x,y))
# diagram = full_diagram(expr)

cart_expr = to_cart_expr(expr)
# markov_expr = to_markov_expr(expr)

d2 = to_wiring_diagram(cart_expr)
simplified_expr = to_hom_expr(FreeCartesianCategory, d2)

# plot(diagram, "test.png")
