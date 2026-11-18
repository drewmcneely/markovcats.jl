using Catlab.WiringDiagrams.DirectedWiringDiagrams

abstract type EnvironmentEntry end

const MarkovEnv = Dict{Symbol, EnvironmentEntry}

struct DiagramEntry <: EnvironmentEntry
    diagram::WiringDiagram
end

@kwdef struct ConditionalEntry <: EnvironmentEntry
    boundary::WiringDiagram
    inner_diagram::WiringDiagram
    cond_vars::Vector{Symbol}
end

struct GeneratorEntry{HomType} <: EnvironmentEntry
    generator::HomType
end
