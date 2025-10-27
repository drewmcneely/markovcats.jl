module MiniDefineDSL

"Symbolic variables for the DSL"
struct Var
    name::Symbol
end
Base.show(io::IO, v::Var) = print(io, String(v.name))

"Conditional y|x as a first-class node"
struct Cond
    out::Var
    given::Vector{Var}
end
Base.show(io::IO, c::Cond) = print(io, "$(c.out)|", join(string.(getfield.(c.given, :name)), ","))

"Overload | so y|x builds a Cond (only for our Var)"
(|)(y::Var, x::Var) = Cond(y, [x])
(|)(y::Var, c::Cond) = Cond(y, [c.out; c.given...])  # allow y|(x|z)

"Simple registry: (fname, out, givens) ↦ rhs AST"
const FACTORS = Dict{Tuple{Symbol,Symbol,Vector{Symbol}}, Any}()

"Register a conditional definition"
function define_conditional(fname::Symbol, c::Cond, rhs_ast::Expr)
    key = (fname, c.out.name, [v.name for v in c.given])
    FACTORS[key] = rhs_ast
    return nothing
end

"@vars x y z  →  x=Var(:x); y=Var(:y); z=Var(:z)"
macro vars(names...)
    assigns = [:( $(esc(n)) = Var($(QuoteNode(n))) ) for n in names]
    Expr(:block, assigns...)
end

"""
@define f(y|x) = rhs

Grabs the pretty LHS, and stores a (fname, Cond) → quoted RHS mapping.
We quote the RHS so it isn't evaluated now; you can interpret/transform it later.
"""
macro define(ex)
    @assert ex.head == :(=)  "Use @define f(y|x) = rhs"
    lhs, rhs = ex.args
    @assert lhs.head == :call "Left side must look like f(y|x)"
    fname = lhs.args[1]       # :f
    cond  = lhs.args[2]       # :(y | x)  (raw syntax; will evaluate to Cond at runtime)
    return :( define_conditional($(QuoteNode(fname)), $(esc(cond)), $(Expr(:quote, rhs))) )
end

end # module
