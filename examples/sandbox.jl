using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using MarkovCats


f = Box(:f, [:A], [:B])
g = Box(:g, [:B], [:C])
h = Box(:h, [:C], [:D])

d = WiringDiagram([:A], [:C])

fv = add_box!(d, f)
gv = add_box!(d, g)

add_wires!(d, [
  (input_id(d),1) => (fv,1),
  (fv,1) => (gv,1),
  (gv,1) => (output_id(d),1),
])

g = show_diagram(d)
