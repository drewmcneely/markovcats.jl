ins(expr::KernelExpr)::Vector{Symbol} = expr.inputs
outs(expr::KernelExpr)::Vector{Symbol} = expr.outputs

ins(expr::AssignmentExpr)::Vector{Symbol} = ins(expr.lhs)
outs(expr::AssignmentExpr)::Vector{Symbol} = outs(expr.lhs)

ins(expr::SumExpr)::Vector{Symbol} = ins(expr.body)
function outs(expr::SumExpr)::Vector{Symbol}
	syms = outs(expr.body)
	for sym in expr.vars
		deleteat!(syms, findall(x -> x==sym, syms))
	end
	return syms
end

# This may break the convention of the functions above, since this does not calculate ins of the boundary but instead concatenates the ins of every block in the product.
ins(expr::ProductExpr)::Vector{Symbol} = vcat(ins.(expr.factors)...)
outs(expr::ProductExpr)::Vector{Symbol} = vcat(outs.(expr.factors)...)


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


# function validate_boxes(boxes::Vector{Box})
# 
#     # Kahn topo sort
#     q = Int[]
#     for i in 1:n
#         indeg[i] == 0 && push!(q, i)
#     end
# 
#     topo = Int[]
#     while !isempty(q)
#         v = pop!(q)
#         push!(topo, v)
#         for w in adj[v]
#             indeg[w] -= 1
#             indeg[w] == 0 && push!(q, w)
#         end
#     end
# 
#     length(topo) == n || error("Cycle detected: boxes cannot be topologically ordered")
# 
#     # D: boundary labels (optional return values)
#     all_ins  = Set(Iterators.flatten(b.ins for b in boxes))
#     all_outs = Set(keys(out_owner))
# 
#     external_inputs  = setdiff(all_ins, all_outs)
#     external_outputs = setdiff(all_outs, all_ins)
# 
#     return (topo=topo, external_inputs=external_inputs, external_outputs=external_outputs)
# end


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
