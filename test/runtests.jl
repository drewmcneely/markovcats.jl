using Test
using MarkovCats

include("fixtures.jl")

@testset "Full Pipeline Unit Test" begin
    expr_block = Fixtures.expr_block
    px_concrete = Fixtures.px_concrete
    f_concrete = Fixtures.f_concrete
    g_concrete = Fixtures.g_concrete
    gen_map = Dict(:px => px_concrete, :f => f_concrete, :g => g_concrete)
    expected_result = Fixtures.expected_result
    result = run_markov_program(GaussStateSpace,
                                GaussianKernel,
                                expr_block,
                                gen_map)
    @test result == expected_result
end

# @testset "KernelExpr Unit Test" begin
# 
# end
# 
# @testset "Full Pipeline Kernel Composition" begin
# 	fixed_exp = Fixtures.Compose.exp
# 	fixed_unmatched_portgraph = Fixtures.Compose.unmatched_pg
# 	fixed_matched_portgraph = Fixtures.Compose.matched_pg
# 
# 	parsed_exp = fixed_exp |> parse_expr
# 
# 	kernel_list = parsed_exp |> flatten |> count_duplicates
# 	unmatched_portgraph = kernel_list |> PortGraph
# 	@test equivalent_portgraphs(unmatched_portgraph, fixed_unmatched_portgraph)
# 	matched_portgraph = unmatched_portgraph |> matching
# 	@test equivalent_portgraphs(matched_portgraph, fixed_matched_portgraph)
# end

# @testset "Full Pipeline Chapman-Kolmogorov" begin
# end
# 
# @testset "Full Pipeline Conditional Independence" begin
# end
# 
# @testset "Full Pipeline Independent-Output Kernels" begin
# end

# @testset "ParsedExprs" begin
# 	composition_expr = :( h(z|x) = sum(y)( g(z|y) * f(y|x) ) )
# 	composition_parsed_expr = composition_expr |> parse_expr
# end
