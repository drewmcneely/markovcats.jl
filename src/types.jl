abstract type EnvEntry{T} end

struct MarkovEnv{T}
    dict::Dict{Symbol, EnvEntry{T}}
end

MarkovEnv{T}(p::Pair{Symbol, EnvEntry{T}}) where {T} = MarkovEnv{T}(Dict(p))

Base.merge(e1::MarkovEnv{T}, e2::MarkovEnv{T}) where {T} = MarkovEnv{T}(merge(e1.dict, e2.dict))
Base.merge(e1::MarkovEnv{T}, e2::MarkovEnv{T}, es::MarkovEnv{T}...) where {T} = merge(merge(e1, e2), es...)
Base.getindex(env::MarkovEnv{T}, k::Symbol) where {T} = env.dict[k]
Base.haskey(env::MarkovEnv{T}, k::Symbol) where {T} = haskey(env.dict, k)

struct HomEntry{T} <: EnvEntry{T}
    morphism::T
end

# Not designed for the parsing stage
# This is more for wiring diagrams and homexprs
@kwdef struct CondEntry{T} <: EnvEntry{T}
    boundary::T
    innards::T
    input_vars::Vector{Symbol}
    output_vars::Vector{Symbol}
    cond_vars::Vector{Symbol}
end
