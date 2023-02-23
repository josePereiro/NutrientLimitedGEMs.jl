## ------------------------------------------------------------------
@time begin
    using NutrientLimitedGEMs
    const NL = NutrientLimitedGEMs

    using ProjAssistant
    using Gurobi
    using MetXBase
    
    using Plots
    
end

# ------------------------------------------------------------------
include("0_params.jl")

## ------------------------------------------------------------------
# Trajectories
_plot_bash1("ECOLI_CORE", EP_ENTROPY_ALG_VERSION;
    biom_lims = (0.0, 0.7), 
    m_glcs_lims = (0.0, 0.10)
)

## ------------------------------------------------------------------
# Entropy
_plot_bash2("ECOLI_CORE", EP_ENTROPY_ALG_VERSION;
    biom_lims = (0.0, 0.7),
)

## ------------------------------------------------------------------