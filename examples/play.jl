@vars x y z
g = Kernel(:g, (z | y));
f = Kernel(:f, (y | x));
test_morphisms = [f, g, copy(y), discard(y)]
