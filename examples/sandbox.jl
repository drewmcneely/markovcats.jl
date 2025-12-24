using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using MarkovCats

expr = :( g(y,z|x,c) * f(x|c) * k(b|x,a,c) * h(a|y) )
md = markov_pipeline(expr)
plot(md, "test-product.png")
