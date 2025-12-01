function Base.show(io::IO, pg::PortGraph)
	for p in pg.boundary_inputs
		show(io, p)
		print(" ")
	end
	print(" || ")
	for p in pg.outputs
		show(io, p)
		print(" ")
	end
	print("\n\n")
	for p in pg.inputs
		show(io, p)
		print(" ")
	end
	print(" || ")
	for p in pg.boundary_outputs
		show(io, p)
		print(" ")
	end
	print("\n\n")
	for (a,b) in pg.edges
		show(io, a)
		print(" -> ")
		show(io, b)
		print("\n")
	end
end

using Cairo, Fontconfig
using Compose
using GraphPlot
using Graphs
using Colors  # only if you want colors; you can remove this

"""
    bipartite_coords(g::SimpleGraph, n_left::Int)

Assumes vertices 1:n_left are on the left, n_left+1:nv(g) on the right.
Returns (locs_x, locs_y) coordinate vectors.
"""
function bipartite_coords(g::SimpleGraph, n_left::Int)
    n = nv(g)
    locs_x = zeros(Float64, n)
    locs_y = zeros(Float64, n)

    # Left side vertices: 1:n_left
    for (i, v) in enumerate(1:n_left)
        locs_x[v] = 0.0
        locs_y[v] = i
    end

    # Right side vertices: n_left+1:n
    for (i, v) in enumerate(n_left+1:n)
        locs_x[v] = 1.0
        locs_y[v] = i
    end
		locs_x .*= 0.25

    return locs_x, locs_y
end

function plot(pg::PortGraph, filename::String)
    # 1. Underlying simple graph from your constructor
    g = SimpleGraph(pg)

    # 2. Ports in the SAME order you used in SimpleGraph(pg)
    #    Here I'm assuming you used vcat(left_ports, right_ports)
		ports = nodes(pg)

    @assert length(ports) == nv(g) "ports vector must match number of vertices in g"

    # 3. Labels using your Base.show(::IO, ::Port)
    labels = [sprint(show, p) for p in ports]

    # 4. Coordinates: first length(left_ports) are left side
		n_left = length(pg.boundary_inputs) + length(pg.outputs)
    locs_x, locs_y = bipartite_coords(g, n_left)

    # 5. Optional: color-code left vs right for sanity
    nodefillc = [v <= n_left ? colorant"lightseagreen" : colorant"orange"
                 for v in vertices(g)]

    ctx = gplot(
        g,
        locs_x, locs_y;
        nodelabel     = labels,
        nodelabeldist = 0.15,
        nodefillc     = nodefillc,  # remove if you don't care about color
				NODELABELSIZE = 18.0,
				nodelabelsize = 1.0,
				EDGELINEWIDTH = 2.5,
				edgelinewidth = 3.0,
    )

    draw(PNG(filename * ".png", 1000, 600), ctx)
end
