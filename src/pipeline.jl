# The following provides an outline of the pipeline
# A morphism starts its life as an Expr
# This then turns into a ParsedExpr, whose structure can be found in src/parsedexpr/types.jl

function parse(expr::Expr)
	return expr |> parse_expr
