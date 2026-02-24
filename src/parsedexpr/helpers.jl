ins(expr::KernelExpr)::Vector{Symbol} = expr.inputs
outs(expr::KernelExpr)::Vector{Symbol} = expr.outputs

ins(expr::AssignmentExpr)::Vector{Symbol} = ins(expr.lhs)
outs(expr::AssignmentExpr)::Vector{Symbol} = outs(expr.lhs)

ins(expr::SumExpr)::Vector{Symbol} = ins(expr.body)
outs(expr::SumExpr)::Vector{Symbol} = filter( s -> !(s in expr.vars), outs(expr.body))

ins(expr::ProductExpr)::Vector{Symbol} = filter( s -> !(s in outs(expr)),  unique(vcat(ins.(expr.factors)...)))
outs(expr::ProductExpr)::Vector{Symbol} = vcat(outs.(expr.factors)...)

findall_inputs(sym::Symbol, expr::ProductExpr)::Vector{Tuple{<:ParsedExpr, Int}} = filter( x -> x != nothing, [sym in ins(e) ? (e, findfirst((x -> x==sym).(ins(e)))) : nothing for e in expr.factors])

# Variable Semantics Checkers/Assertions

# D. Boundary labels (optional, but super useful)
# 
# Given the boxes, you can classify labels into:
# 
#     External inputs: labels used as inputs but never produced as an output.
#     External outputs: labels produced as outputs but never used later as an input.
#     external_inputs = all_inputs \ all_outputs
#     external_outputs = all_outputs \ all_inputs
# 

depends_on(b::ParsedExpr, a::ParsedExpr) = any([i in outs(a) for i in ins(b)])
# @assert !(has_cycle(k)) for all KernelExpr k
has_cycle(expr::KernelExpr) = depends_on(expr, expr)
# @assert !(has_duplicates(outs(expr))) for any ParsedExpr
# @assert !(has_duplicates(ins(expr))) for all KernelExpr expr
has_duplicates(syms::Vector{Symbol}) = length(unique(syms)) != length(syms)

"""
    topological_sort(g::ProductDependencyGraph) -> Vector{ParsedExpr}

Returns a topological ordering of `g.nodes`.

Throws an error if:
- an edge references a node not in `g.nodes`, or
- the graph contains a directed cycle (i.e. no topological order exists).
"""
function topological_sort(g::ProductDependencyGraph)::Vector{ParsedExpr}
    # Quick membership structure for validation
    node_set = Set(g.nodes)

    # adjacency list and indegree map
    adj = Dict{ParsedExpr, Vector{ParsedExpr}}()
    indeg = Dict{ParsedExpr, Int}()

    # initialize for all nodes (including isolated nodes)
    for v in g.nodes
        adj[v] = ParsedExpr[]
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
    q = ParsedExpr[]
    for v in g.nodes
        if indeg[v] == 0
            push!(q, v)
        end
    end

    # produce ordering
    order = ParsedExpr[]
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
        remaining = ParsedExpr[]
        for v in g.nodes
            if indeg[v] > 0
                push!(remaining, v)
            end
        end
        error("Expression has circular dependencies! Nodes still with indegree>0: $(remaining)")
    end

    return order
end

nameof(expr::AssignmentExpr) = nameof(expr.lhs)
nameof(expr::KernelExpr) = expr.name
