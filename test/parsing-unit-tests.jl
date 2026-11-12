using MarkovCats: KernelExpr, SumExpr, ProductExpr, AssignmentExpr, BlockExpr, CondExpr

@testset "KernelExpr Unit Tests" begin
    @test parse_expr(:( p(x)   )) == KernelExpr(:p, [:x], Symbol[])
    @test parse_expr(:( p(x,y)   )) == KernelExpr(:p, [:x, :y], Symbol[])
    @test parse_expr(:( p(y|x) )) == KernelExpr(:p, [:y], [:x])
    @test parse_expr(:( p(y,z|x) )) == KernelExpr(:p, [:y, :z], [:x])
    @test parse_expr(:( p(x|a,b) )) == KernelExpr(:p, [:x], [:a, :b])
    @test parse_expr(:( p(x,y|a,b) )) == KernelExpr(:p, [:x, :y], [:a, :b])
end

@testset "SumExpr Unit Tests" begin
    @test parse_expr(:( sum(x)( p(x) ) )) == SumExpr([:x], KernelExpr(:p, [:x], Symbol[]))
    @test parse_expr(:( sum(x)( p(x,y) ) )) == SumExpr([:x], KernelExpr(:p, [:x, :y], Symbol[]))
    @test parse_expr(:( sum(x,y)( p(x,y) ) )) == SumExpr([:x,:y], KernelExpr(:p, [:x, :y], Symbol[]))
    
    # Σ (\sigma) and ∑ (\sum) alias
    @test parse_expr(:( Σ(x)( p(x) ) )) == SumExpr([:x], KernelExpr(:p, [:x], Symbol[]))
    @test parse_expr(:( sum(x)( p(x) ) )) == SumExpr([:x], KernelExpr(:p, [:x], Symbol[]))
    @test parse_expr(:( sum(x)( p(x,y) ) )) == SumExpr([:x], KernelExpr(:p, [:x, :y], Symbol[]))
    @test parse_expr(:( sum(x,y)( p(x,y) ) )) == SumExpr([:x,:y], KernelExpr(:p, [:x, :y], Symbol[]))
    # Sum over a product (Chapman-Kolmogorov body)
    @test parse_expr(:( sum(x)( f(y|x) * px(x) ) )) == SumExpr([:x], ProductExpr([
        KernelExpr(:f, [:y], [:x]),
        KernelExpr(:px, [:x], Symbol[]),
    ]))
end

@testset "ProductExpr Unit Tests" begin
    # Independent factors — no dependencies, order preserved
    @test parse_expr(:( px(x) * py(y) )) == ProductExpr([
        KernelExpr(:px, [:x], Symbol[]),
        KernelExpr(:py, [:y], Symbol[]),
    ])
    # Dependent factors — topological sort puts p(x) before f(y|x)
    @test parse_expr(:( f(y|x) * px(x) )) == ProductExpr([
        KernelExpr(:px, [:x], Symbol[]),
        KernelExpr(:f, [:y], [:x]),
    ])
    # Three factors — chain dependency
    @test parse_expr(:( g(z|y) * f(y|x) * px(x) )) == ProductExpr([
        KernelExpr(:px, [:x], Symbol[]),
        KernelExpr(:f, [:y], [:x]),
        KernelExpr(:g, [:z], [:y]),
    ])
end

@testset "AssignmentExpr Unit Tests" begin
    # Simple assignment with sum RHS
    @test parse_expr(:( py(y) = sum(x)( f(y|x) * px(x) ) )) == AssignmentExpr(
        KernelExpr(:py, [:y], Symbol[]),
        SumExpr([:x], ProductExpr([
            KernelExpr(:px, [:x], Symbol[]),
            KernelExpr(:f, [:y], [:x]),
        ]))
    )
    # Assignment with product RHS (graph state)
    @test parse_expr(:( pxy(x,y) = f(y|x) * px(x) )) == AssignmentExpr(
        KernelExpr(:pxy, [:x, :y], Symbol[]),
        ProductExpr([
            KernelExpr(:px, [:x], Symbol[]),
            KernelExpr(:f, [:y], [:x]),
        ])
    )
end

@testset "BlockExpr Unit Tests" begin
    @test parse_expr(:(begin
        py(y) = Σ(x)( f(y|x) * px(x) )
        pz(z) = Σ(y)( g(z|y) * py(y) )
    end)) == BlockExpr([
        AssignmentExpr(
            KernelExpr(:py, [:y], Symbol[]),
            SumExpr([:x], ProductExpr([
                KernelExpr(:px, [:x], Symbol[]),
                KernelExpr(:f, [:y], [:x]),
            ]))
        ),
        AssignmentExpr(
            KernelExpr(:pz, [:z], Symbol[]),
            SumExpr([:y], ProductExpr([
                KernelExpr(:py, [:y], Symbol[]),
                KernelExpr(:g, [:z], [:y]),
            ]))
        ),
    ])
end

@testset "CondExpr Unit Tests" begin
    ex = :( p(y,x) / sum(y)(p(y,x)) )
    condex = CondExpr(
          KernelExpr(:p, [:y,:x], Symbol[]),
          [:x]
         )
    @test parse_expr(ex) == condex
end
