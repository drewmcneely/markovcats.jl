module Fixtures

module Compose
using MarkovCats: outputports, inputports, Var, Kernel, copykernel, discardkernel, KernelList, PortGraph, Port, add_edge!, matching

exp = :( h(z|x) = sum(y)( g(z|y) * f(y|x) ) )

x = Var(:x)
y = Var(:y)
z = Var(:z)

f = Kernel(:f, y|x)
g = Kernel(:g, z|y)
h = Kernel(:h, z|x)
copy_y = copykernel(y)
disc_y = discardkernel(y)

f_out = outputports(f)[1]
f_in  =  inputports(f)[1]
g_out = outputports(g)[1]
g_in  =  inputports(g)[1]
h_out = outputports(h)[1]
h_in  =  inputports(h)[1]

copy_y_out_1 = outputports(copy_y)[1]
copy_y_out_2 = outputports(copy_y)[2]
copy_y_in = inputports(copy_y)[1]
disc_y_in = inputports(disc_y)[1]

kl = KernelList(h, [g,f,copy_y, disc_y])

pg_outputs = vcat(outputports(g),
									outputports(f),
									outputports(copy_y),
									outputports(disc_y))

pg_inputs = vcat(inputports(g),
									inputports(f),
									inputports(copy_y),
									inputports(disc_y))

pg_boundary_ins = inputports(h)
pg_boundary_outs = outputports(h)

unmatched_pg = PortGraph(pg_outputs,
												 pg_inputs,
												 pg_boundary_ins,
												 pg_boundary_outs,
												 Tuple{Port, Port}[])

add_edge!(unmatched_pg, f_out, g_in)
add_edge!(unmatched_pg, f_out, copy_y_in)
add_edge!(unmatched_pg, f_out, disc_y_in)

add_edge!(unmatched_pg, g_out, h_out)
add_edge!(unmatched_pg, h_in, f_in)

add_edge!(unmatched_pg, copy_y_out_1, g_in)
add_edge!(unmatched_pg, copy_y_out_1, disc_y_in)
add_edge!(unmatched_pg, copy_y_out_2, g_in)
add_edge!(unmatched_pg, copy_y_out_2, disc_y_in)

matched_pg = PortGraph(pg_outputs,
											 pg_inputs,
											 pg_boundary_ins,
											 pg_boundary_outs,
											 Tuple{Port, Port}[])
add_edge!(matched_pg, h_in, f_in)
add_edge!(matched_pg, f_out, copy_y_in)
add_edge!(matched_pg, copy_y_out_1, disc_y_in)
add_edge!(matched_pg, copy_y_out_2, g_in)
add_edge!(matched_pg, g_out, h_out)

end

# # Indepent States
# indep_exp = :( pxy(x,y) = px(x) * py(y) )
# 
# # Independent Kernels
# indep_k_exp = :( pxy(x,y|a) = sum(b)( px(x|b) * py(y|b) * pb(b|a) ) )

end # module
