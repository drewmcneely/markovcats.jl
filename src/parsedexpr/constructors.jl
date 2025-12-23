# function ProductDependencyGraph(expr::ProductExpr)
# 	nodes = expr.factors
# 	edges = unique([a => b for a in nodes for b in nodes if depends_on(b, a)])
# 	return ProductDependencyGraph(nodes, edges)
# end

function ProductDependencyGraph(nodes::Vector{ParsedExpr})
	edges = unique([a => b for a in nodes for b in nodes if depends_on(b, a)])
	return ProductDependencyGraph(nodes, edges)
end
