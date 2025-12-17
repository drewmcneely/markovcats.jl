abstract type ParsedExpr end

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

struct KernelExpr <: ParsedExpr
	name::Symbol
	outputs::Vector{Symbol}
	inputs::Vector{Symbol}
end

