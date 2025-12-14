using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using MarkovCats
#include("../test/fixtures.jl")

# using Catlab.WiringDiagrams
# using Catlab.Graphics
# import Catlab.Graphics.ComposeWiringDiagrams as CompWD
# import Catlab.Graphics.GraphvizWiringDiagrams as GWD
# import GraphViz as GV
# 
# using Cairo, Fontconfig
# using Compose
# using GraphPlot
# using Graphs
# using Colors  # only if you want colors; you can remove this

using Catlab.WiringDiagrams

using Catlab.Graphics
import Catlab.Graphics: Graphviz, GraphvizGraphs


show_diagram(d::WiringDiagram) = to_graphviz(d,
  orientation=LeftToRight,
  labels=true, label_attr=:xlabel,
  node_attrs=Graphviz.Attributes(
    :fontname => "Courier",
  ),
  edge_attrs=Graphviz.Attributes(
    :fontname => "Courier",
  )
)

# function plot_diagram(d::WiringDiagram)
# 	pic = CompWD.to_composejl(d)
# 	draw(PNG("diagram.png", pic.width, pic.height), pic.context)
# end

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
# Graphviz.pprint(stdout, g)

filepath = "graph.png"
# gv = GraphvizGraphs.to_graphviz(d)
gv = show_diagram(d)
open(filepath, "w") do io
	Graphviz.run_graphviz(io, gv, format="png")
end

# import .Fixtures.Compose as FC
# upg = FC.pg
# apg = FC.auto_matched_pg
# mpg = FC.manual_matched_pg
# 
# println(portgraph_signature(apg))
# println(portgraph_signature(mpg))
# println(equivalent_portgraphs(apg, mpg))

# @kernelassignments begin
# 	# Kernel Composition
# 	h(z|x) = sum(y)( g(z|y) * f(y|x) )
# 
# 	# Chapman-Kolmogorov Equation
# 	p_y(y) = sum(x)( f(y|x) * p_x(x) )
# 
# 	# Conditional Independence
# 	# k(x,y|a) = sum(b)( g(x|b) * h(y|b) * f(b|a) )
# 	# ^^^ This breaks the LP solver ^^^
# 	# I think because b shows up 3 times, requiring 2 comultipliers
# 	# which can create matching cycles
# end
# 
# plot(h, "compose_plot")
# plot(p_y, "ck_plot")
