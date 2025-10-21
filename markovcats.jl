abstract type Morphism end
abstract type MonoidalMorphism <: Morphism end
abstract type SymmetricMonoidalMorphism <: MonoidalMorphism end
abstract type MarkovMorphism <: SymmetricMonoidalMorphism end

abstract type CatObject end
abstract type MonoidalObject <: CatObject end
abstract type SymmetricMonoidalObject <: MonoidalObject end
abstract type MarkovObject <: SymmetricMonoidalObject end

