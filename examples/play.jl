using .MarkovCats

function example_wiring()
	@vars x y z
	g = Kernel(:g, (z | y));
	f = Kernel(:f, (y | x));
	test_morphisms = [f, g, copykernel(y), discardkernel(y)]

	w = possiblewiring(test_morphisms)
end

function render(w)
	plot(w)
end
