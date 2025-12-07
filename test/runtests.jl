using Test
using MarkovCats

include("fixtures.jl")

@testset "Full Pipeline Kernel Composition" begin
	fixed_exp = Fixtures.Compose.exp
	fixed_unmatched_portgraph = Fixtures.Compose.unmatched_pg
	fixed_matched_portgraph = Fixtures.Compose.matched_pg

	parsed_exp = fixed_exp |> parse_expr

	kernel_list = parsed_exp |> flatten |> count_duplicates
	unmatched_portgraph = kernel_list |> PortGraph
	@test equivalent_portgraphs(unmatched_portgraph, fixed_unmatched_portgraph)
	matched_portgraph = unmatched_portgraph |> matching
	@test equivalent_portgraphs(matched_portgraph, fixed_matched_portgraph)
end

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
