abstract type EnvEntry{T} end

struct MarkovEnv{T}
    dict::Dict{Symbol, EnvEntry{T}}
end

MarkovEnv{T}(p::Pair{Symbol, EnvEntry{T}}) where {T} = MarkovEnv{T}(Dict(p))

merge(e1::MarkovEnv{T}, e2::MarkovEnv{T}) where {T} = MarkovEnv{T}(merge(e1.dict, e2.dict))
merge(e1::MarkovEnv{T}, e2::MarkovEnv{T}, es::MarkovEnv{T}...) where {T} = merge(merge(e1, e2), es...)

struct HomEntry{T} <: EnvEntry{T}
    morphism::T
end

# Not designed for the parsing stage
# This is more for wiring diagrams and homexprs
@kwdef struct CondEntry{T} <: EnvEntry{T}
    boundary::T
    innards::T
    cond_vars::Vector{Symbol}
end
