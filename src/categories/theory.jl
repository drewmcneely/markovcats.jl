using Catlab.Theories

""" Theory of *Markov categories*
"""
@theory ThMarkovCategory <: ThMonoidalCategoryWithDiagonals begin
  # pair(f::(A → B), g::(A → C))::(A → (B ⊗ C)) ⊣ [A::Ob, B::Ob, C::Ob]
  # proj1(A::Ob, B::Ob)::((A ⊗ B) → A)
  # proj2(A::Ob, B::Ob)::((A ⊗ B) → B)

  # # Definitions of pairing and projections.
  # pair(f,g) == Δ(C)⋅(f⊗g) ⊣ [A::Ob, B::Ob, C::Ob, f::(C → A), g::(C → B)]
  # proj1(A,B) == id(A)⊗◊(B) ⊣ [A::Ob, B::Ob]
  # proj2(A,B) == ◊(A)⊗id(B) ⊣ [A::Ob, B::Ob]
  
  # Naturality axioms.
  f⋅◊(B) == ◊(A) ⊣ [A::Ob, B::Ob, f::(A → B)]
end


""" Syntax for a free cartesian category.

In this syntax, the pairing and projection operations are defined using
duplication and deletion, and do not have their own syntactic elements.
This convention could be dropped or reversed.
"""
@symbolic_model FreeMarkovCategory{ObExpr,HomExpr} ThMarkovCategory begin
  otimes(A::Ob, B::Ob) = associate_unit(new(A,B), munit)
  otimes(f::Hom, g::Hom) = associate(new(f,g))
  compose(f::Hom, g::Hom) = associate_unit(new(f,g; strict=true), id)

  # pair(f::Hom, g::Hom) = compose(mcopy(dom(f)), otimes(f,g))
  # proj1(A::Ob, B::Ob) = otimes(id(A), delete(B))
  # proj2(A::Ob, B::Ob) = otimes(delete(A), id(B))
end

show_latex(io::IO, expr::HomExpr{:mcopy}; kw...) =
  show_latex_script(io, expr, "\\Delta")
show_latex(io::IO, expr::HomExpr{:delete}; kw...) =
  show_latex_script(io, expr, "\\lozenge")
