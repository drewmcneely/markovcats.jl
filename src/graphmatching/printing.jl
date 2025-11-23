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

