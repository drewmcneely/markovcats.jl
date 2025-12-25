using Catlab.Theories: FreeCartesianCategory
using Catlab.WiringDiagramExpressions

markov_pipeline(expr::Expr) = expr |> parse_expr |> WiringDiagram

function morphism(expr::Expr) 
	d = markov_pipeline(expr)
	return to_hom_expr(FreeCartesianCategory, d)
end

full_diagram(expr::Expr) = expr |> morphism |> to_wiring_diagram
