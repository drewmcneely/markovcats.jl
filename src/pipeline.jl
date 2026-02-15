using Catlab.Theories: FreeCartesianCategory
using Catlab.WiringDiagramExpressions

WiringDiagramExpressions.to_wiring_diagram(expr::Expr) = expr |> parse_expr |> WiringDiagram

to_cart_expr(expr::Expr) = to_hom_expr(FreeCartesianCategory, to_wiring_diagram(expr))
# to_markov_expr(expr::Expr) = to_hom_expr(FreeMarkovCategory, to_wiring_diagram(expr))
