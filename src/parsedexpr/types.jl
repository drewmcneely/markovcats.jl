abstract type ParsedExpr end

struct KernelExpr <: ParsedExpr
  # name( outputs | inputs )
	name::Symbol
	outputs::Vector{Symbol}
	inputs::Vector{Symbol}
end

struct AssignmentExpr <: ParsedExpr
  # lhs = rhs
	lhs::KernelExpr
	rhs::ParsedExpr
end

struct SumExpr <: ParsedExpr
  # ∑(vars)( body )
	vars::Vector{Symbol}
	body::ParsedExpr
end

struct ProductExpr <: ParsedExpr
  # expr * expr
	factors::Vector{ParsedExpr}
  # Constructor does a topological sort to check there are no cycles in the expr
  # eg. p(y|x) * p(x|y) is not allowed
	ProductExpr(factors) = new(factors |> ProductDependencyGraph |> topological_sort)
end

struct ProductDependencyGraph
	nodes::Vector{ParsedExpr}
	edges::Vector{Pair{ParsedExpr, ParsedExpr}}
end

struct BlockExpr <: ParsedExpr
    statements::Vector{AssignmentExpr}
end

struct CondExpr <: ParsedExpr
    # top / bottom
    top::ParsedExpr
    # bottom::ParsedExpr
    vars::Vector{Symbol}
end
