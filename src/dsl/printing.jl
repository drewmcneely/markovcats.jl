# Var printers
Base.show(io::IO, v::Var) = print(io, v.name)

function to_string(v::Vector{Var})
	names = [String(n.name) for n in v]
	return join(names, ",")
end

# Signature printers
function Base.show(io::IO, sig::Signature)
	target = to_string(sig.target)
	source = to_string(sig.source)
	print(io, string("( ", target, " | ", source, " )"))
end
