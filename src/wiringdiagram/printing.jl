using Catlab.Graphics
import Catlab.Graphics: Graphviz, GraphvizGraphs

to_graphviz(d::WiringDiagram) = to_graphviz(d,
  orientation=LeftToRight,
  labels=true, label_attr=:xlabel,
  node_attrs=Graphviz.Attributes(
    :fontname => "Courier",
  ),
  edge_attrs=Graphviz.Attributes(
    :fontname => "Courier",
  )
)

function plot(d::WiringDiagram, filepath::String)
	gv = to_graphviz(d)
	open(filepath, "w") do io
		Graphviz.run_graphviz(io, gv, format="png")
	end
end
