using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using MarkovCats

# expr = :( j(z,a,x,b|c,d) = sum(y)( g(y,z|x,c) * f(x|c) * k(b|x,a,c) * h(a|y) ) )
expr = :( py(y) = sum(x)( f(y|x) * px(x) ) )
# diagram = full_diagram(expr)
hom_expr = morphism(expr)
println(hom_expr)
# plot(diagram, "test.png")
