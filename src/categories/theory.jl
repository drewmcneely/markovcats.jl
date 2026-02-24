using Catlab.Theories

""" Theory of *Markov categories* without conditionals
"""
@theory ThMarkovCategory <: ThMonoidalCategoryWithDiagonals begin
  # Naturality axiom.
  f⋅◊(B) == ◊(A) ⊣ [A::Ob, B::Ob, f::(A → B)]
end


""" Syntax for a free Markov category.

In this syntax, the pairing and projection operations are defined using
duplication and deletion, and do not have their own syntactic elements.
This convention could be dropped or reversed.
"""
@symbolic_model FreeMarkovCategory{ObExpr,HomExpr} ThMarkovCategory begin
  otimes(A::Ob, B::Ob) = associate_unit(new(A,B), munit)
  otimes(f::Hom, g::Hom) = associate(new(f,g))

  # TODO: In order to be able to uncomment the below line, I have to figure out
  # how to specify associated composition in the instance.
  # Is it a matter of just defining a composition chain by a fold?
  ## compose(f::Hom, g::Hom) = associate_unit(new(f,g; strict=true), id)
end

show_latex(io::IO, expr::HomExpr{:mcopy}; kw...) =
  show_latex_script(io, expr, "\\Delta")
show_latex(io::IO, expr::HomExpr{:delete}; kw...) =
  show_latex_script(io, expr, "\\lozenge")
