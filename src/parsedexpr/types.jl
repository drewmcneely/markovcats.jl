using StructEquality

###################
# Environment Types
###################

abstract type ParsedEntry end

struct ParsedEnv
    dict::Dict{Symbol, ParsedEntry}
end

struct GeneratorEntry{HomType} <: ParsedEntry
    generator::HomType
end

###################
# Expression Types
###################

abstract type ParsedExpr end

@struct_hash_equal struct KernelExpr <: ParsedExpr
  # name( outputs | inputs )
	name::Symbol
	outputs::Vector{Symbol}
	inputs::Vector{Symbol}
end

@struct_hash_equal struct AssignmentExpr <: ParsedExpr
  # lhs = rhs
	lhs::KernelExpr
	rhs::ParsedExpr
end

@struct_hash_equal struct SumExpr <: ParsedExpr
  # ∑(vars)( body )
	vars::Vector{Symbol}
	body::ParsedExpr
end

@struct_hash_equal struct ProductExpr <: ParsedExpr
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

@struct_hash_equal struct BlockExpr <: ParsedExpr
    statements::Vector{AssignmentExpr}
end

@struct_hash_equal struct CondExpr <: ParsedExpr
    # top / bottom
    top::ParsedExpr
    # bottom::ParsedExpr
    vars::Vector{Symbol}
end
