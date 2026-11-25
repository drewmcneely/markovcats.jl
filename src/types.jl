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

struct DependencyGraph{T}
	nodes::Vector{T}
	edges::Vector{Pair{T, T}}
end

function topological_sort(g::DependencyGraph{T})::Vector{T} where {T}
    # Quick membership structure for validation
    node_set = Set(g.nodes)

    # adjacency list and indegree map
    adj = Dict{T, Vector{T}}()
    indeg = Dict{T, Int}()

    # initialize for all nodes (including isolated nodes)
    for v in g.nodes
        adj[v] = T[]
        indeg[v] = 0
    end

    # build graph structures
    for e in g.edges
        u, v = e.first, e.second

        if !(u in node_set) || !(v in node_set)
            error("Edge references node not in g.nodes: $(u) => $(v)")
        end

        push!(adj[u], v)
        indeg[v] = indeg[v] + 1
    end

    # initialize queue with all zero-indegree nodes
    q = T[]
    for v in g.nodes
        if indeg[v] == 0
            push!(q, v)
        end
    end

    # produce ordering
    order = T[]
    front = 1  # avoid O(n) popfirst!
    while front <= length(q)
        u = q[front]; front += 1
        push!(order, u)

        for v in adj[u]
            indeg[v] -= 1
            if indeg[v] == 0
                push!(q, v)
            end
        end
    end

    # cycle check
    if length(order) != length(g.nodes)
        remaining = T[]
        for v in g.nodes
            if indeg[v] > 0
                push!(remaining, v)
            end
        end
        error("Expression has circular dependencies! Nodes still with indegree>0: $(remaining)")
    end

    return order
end
