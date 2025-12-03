using Test
using MarkovCats

@testset "Kernel Composition" begin
	expr = :( h(z|x) = sum(y)( g(z|y) * f(y|x) ) )
	pe = expr |> parse_expr




	kl = pe |> flatten |> count_duplicates
	unmatched_pg = kl |> PortGraph
	matched_pg = unmatched_pg |> matching
end

@testset "ParsedExprs" begin
	composition_expr = :( h(z|x) = sum(y)( g(z|y) * f(y|x) ) )
	composition_pe = composition_expr |> parse_expr

	

	composition_test_pe = 

