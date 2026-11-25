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

function Base.show(io::IO, entry::HomEntry{WiringDiagram})
    print(io,
          "( :: ",
          input_ports(entry.morphism),
          " → ",
          output_ports(entry.morphism),
          " )")
end

function Base.show(io::IO, entry::CondEntry{WiringDiagram})
    print(io,
          "( :: ",
          input_ports(entry.innards),
          " → ",
          output_ports(entry.innards),
          " / ",
          entry.cond_vars,
          " )")

end

# function Base.show(io::IO, env::MarkovEnv)
# end
