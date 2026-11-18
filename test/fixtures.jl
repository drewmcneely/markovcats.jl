using MarkovCats: outputports, inputports, Var, Kernel, copykernel, discardkernel, KernelList, PortGraph, Port, add_edge!, matching

exp = :( h(z|x) = sum(y)( g(z|y) * f(y|x) ) )

expr_block = :(begin
                   py(y) = Σ(x)( f(y|x) * px(x) )
                   pz(z) = Σ(y)( g(z|y) * py(y) )
               end)

px_concrete = 𝓝([1, 2], [1 1; 1 2])
f_concrete  = GaussianKernel([2 0; 0 2], [2, 3], [4 5; 5 6])
g_concrete  = GaussianKernel([1 2; 3 4], [2, 3], [2 0; 0 2])


expected_result = Dict{Symbol, GaussianKernel}(:pz => GaussianKernel(Matrix{Float64}(undef, 2, 0), [20.0, 43.0], [102.0 226.0; 226.0 514.0]), :py => GaussianKernel(Matrix{Float64}(undef, 2, 0), [4.0, 7.0], [8.0 9.0; 9.0 14.0]))



# x = Var(:x)
# y = Var(:y)
# z = Var(:z)
# 
# f = Kernel(:f, y|x)
# g = Kernel(:g, z|y)
# h = Kernel(:h, z|x)
# copy_y = copykernel(y)
# disc_y = discardkernel(y)
# 
# f_out = outputports(f)[1]
# f_in  =  inputports(f)[1]
# g_out = outputports(g)[1]
# g_in  =  inputports(g)[1]
# h_out = outputports(h)[1]
# h_in  =  inputports(h)[1]
# 
# copy_y_out_1 = outputports(copy_y)[1]
# copy_y_out_2 = outputports(copy_y)[2]
# copy_y_in = inputports(copy_y)[1]
# disc_y_in = inputports(disc_y)[1]
# 
# kl = KernelList(h, [g,f,copy_y, disc_y])
# 
# pg_outputs = vcat(outputports(g),
# 									outputports(f),
# 									outputports(copy_y),
# 									outputports(disc_y))
# 
# pg_inputs = vcat(inputports(g),
# 									inputports(f),
# 									inputports(copy_y),
# 									inputports(disc_y))
# 
# pg_boundary_ins = inputports(h)
# pg_boundary_outs = outputports(h)
# 
# unmatched_pg = PortGraph(pg_outputs,
# 												 pg_inputs,
# 												 pg_boundary_ins,
# 												 pg_boundary_outs,
# 												 Tuple{Port, Port}[])
# 
# add_edge!(unmatched_pg, f_out, g_in)
# add_edge!(unmatched_pg, f_out, copy_y_in)
# add_edge!(unmatched_pg, f_out, disc_y_in)
# 
# add_edge!(unmatched_pg, g_out, h_out)
# add_edge!(unmatched_pg, h_in, f_in)
# 
# add_edge!(unmatched_pg, copy_y_out_1, g_in)
# add_edge!(unmatched_pg, copy_y_out_1, disc_y_in)
# add_edge!(unmatched_pg, copy_y_out_2, g_in)
# add_edge!(unmatched_pg, copy_y_out_2, disc_y_in)
# 
# matched_pg = PortGraph(pg_outputs,
# 											 pg_inputs,
# 											 pg_boundary_ins,
# 											 pg_boundary_outs,
# 											 Tuple{Port, Port}[])
# add_edge!(matched_pg, h_in, f_in)
# add_edge!(matched_pg, f_out, copy_y_in)
# add_edge!(matched_pg, copy_y_out_1, disc_y_in)
# add_edge!(matched_pg, copy_y_out_2, g_in)
# add_edge!(matched_pg, g_out, h_out)
# 
# end

# # Indepent States
# indep_exp = :( pxy(x,y) = px(x) * py(y) )
# 
# # Independent Kernels
# indep_k_exp = :( pxy(x,y|a) = sum(b)( px(x|b) * py(y|b) * pb(b|a) ) )
