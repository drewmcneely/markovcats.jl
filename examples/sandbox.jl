using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using MarkovCats

@kernelassignments begin
	# Kernel Composition
	h(z|x) = sum(y)( g(z|y) * f(y|x) )

	# Chapman-Kolmogorov Equation
	p_y(y) = sum(x)( f(y|x) * p_x(x) )

	# Conditional Independence
	# k(x,y|a) = sum(b)( g(x|b) * h(y|b) * f(b|a) )
	# ^^^ This breaks the LP solver ^^^
	# I think because b shows up 3 times, requiring 2 comultipliers
	# which can create matching cycles
end

plot(h, "compose_plot")
plot(p_y, "ck_plot")
