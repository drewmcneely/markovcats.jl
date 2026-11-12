@kwdef struct WiringEnv
    symbol_table::Dict{Symbol, WiringDiagram} = Dict()
    cond_inner_diagram::Dict{Symbol, Symbol} = Dict()
    cond_outer_box::Dict{Symbol, Symbol} = Dict()
end
