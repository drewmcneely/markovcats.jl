using Catlab.Graphics
import Catlab.Graphics: Graphviz, GraphvizGraphs

apply_props(d::WiringDiagram) = to_graphviz(d,
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
  print(d)
	gv = apply_props(d)
	open(filepath, "w") do io
		Graphviz.run_graphviz(io, gv, format="png")
	end
end

function Base.show(io::IO, entry::DiagramEntry)
    print(io,
          "(DiagramEntry ",
          input_ports(entry.diagram),
          " → ",
          output_ports(entry.diagram),
          " )")
end

function Base.show(io::IO, entry::CondDiagramEntry)
    print(io,
          "(CondDiagramEntry ",
          input_ports(entry.inner_diagram),
          " → ",
          output_ports(entry.inner_diagram),
          " / ",
          entry.cond_vars,
          " )")

end

# function Base.show(io::IO, env::MarkovEnv)
# end
