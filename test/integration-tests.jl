
@testset "Gaussian Chapman-Kolmogorov Integration Test" begin

    expr_block = :(begin
                       py(y) = Σ(x)( f(y|x) * px(x) )
                       pz(z) = Σ(y)( g(z|y) * py(y) )
                   end)

    px_concrete = 𝓝([1, 2], [1 1; 1 2])
    f_concrete  = GaussianKernel([2 0; 0 2], [2, 3], [4 5; 5 6])
    g_concrete  = GaussianKernel([1 2; 3 4], [2, 3], [2 0; 0 2])

    gen_map = Dict(:px => px_concrete, :f => f_concrete, :g => g_concrete)
    result = run_markov_program(GaussStateSpace,
                                GaussianKernel,
                                expr_block,
                                gen_map)

    expected_result = Dict{Symbol, GaussianKernel}(:pz => GaussianKernel(Matrix{Float64}(undef, 2, 0), [20.0, 43.0], [102.0 226.0; 226.0 514.0]), :py => GaussianKernel(Matrix{Float64}(undef, 2, 0), [4.0, 7.0], [8.0 9.0; 9.0 14.0]))


    println(result)
    println(expected_result)

    r = result[:pz]
    e = expected_result[:pz]
    @test r.map == e.map
    @test r.mean == e.mean
    @test r.covariance == e.covariance

end
