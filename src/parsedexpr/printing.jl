function Base.show(io::IO, ex::KernelExpr)
    name = String(ex.name)
    outputs = join(ex.outputs, ", ")
    inputs = join(ex.inputs, ", ")
    print(io, name * "(" * outputs * "|" * inputs * ")" )
end

function Base.show(io::IO, ex::AssignmentExpr)
    print(io, ex.lhs, " = ", ex.rhs)
end

# function Base.show(io::IO, ex::SumExpr)
# end

function Base.show(io::IO, ex::ProductExpr)
    join(io, ex.factors, " * ")
end

function Base.show(io::IO, ex::CondExpr)
    print(io, "{ ", ex.top, " }/{", join(ex.vars, ","), "}")
end
