matches(a::Port, b::Port) = a.var == b.var

ports(k::NamedKernel) = vcat(k.inputports, k.outputports)
signature(k::NamedKernel) = [p.var for p in k.inputports] | [p.var for p in k.outputports]
inputports(ks::AbstractVector{<:Kernel}) = vcat((k -> k.inputports).(ks)...)
inputports(k::Kernel) = inputports([k])
outputports(ks::AbstractVector{<:Kernel}) = vcat((k -> k.outputports).(ks)...)
outputports(k::Kernel) = outputports([k])

# TODO: Make checker functions
# Assert that no port label is an input and output of the same kernel
# Assert that no duplicate outputs are within a box
# Assert that no duplicate inputs are within a box
# 
# Global Uniqueness
# Check that each port label appears as an output at most once
#
# TopSort
# Build a graph of NamedKernels. Edge i -> j if outs(i) intersect ins(j) is not empty
# Run a topological sort on the graph. If it fails, then your graph is not a DAG and the ProductExpr is invalid.
