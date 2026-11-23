# using FreeMarkovCategory:HomExpr

# abstract type HomExprEntry end
# 
# struct HomExprEnv
#     dict::Dict{Symbol, HomExprEntry}
# end
# 
# struct MorphismHomExprEntry <: HomExprEntry
#     morphism::HomExpr
# end
# 
# @kwdef struct CondHomExprEntry <: HomExprEntry
#     boundary::HomExpr
#     innards::HomExpr
#     cond_vars::Vector{Symbol}
# end
# 
