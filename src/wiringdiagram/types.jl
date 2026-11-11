struct WiringEnv
    symbol_table::Dict{Symbol, WiringDiagram}
    cond_inner_diagram::Dict{Symbol, Symbol}
    cond_outer_box::Dict{Symbol, Symbol}
end
