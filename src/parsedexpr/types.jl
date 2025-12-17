abstract type ParsedExpr end

struct KernelExpr <: ParsedExpr
	name::Symbol
	outputs::Vector{Symbol}
	inputs::Vector{Symbol}
end

struct AssignmentExpr <: ParsedExpr
	lhs::KernelExpr
	rhs::ParsedExpr
end

struct SumExpr <: ParsedExpr
	vars::Vector{Symbol}
	body::ParsedExpr
end

struct ProductExpr <: ParsedExpr
	factors::Vector{ParsedExpr}
end

struct ProductDependencyGraph
	nodes::Vector{ParsedExpr}
	edges::Vector{Pair{ParsedExpr, ParsedExpr}}
end
