
ex = :( (f(y,x) * p(x) ) / ∑(y)( f(y,x) * p(x) ) )

parsedex = CondExpr( top = parse_expr( :( p(y,x) ) ), vars = :(x) )

p_diag = WiringDiagram(parsed
