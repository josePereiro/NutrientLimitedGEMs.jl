(julia -t5 --project scripts/BEG2007/PHASES_KOMA/7_core_fva.jl -- "SIMVER:ECOLI-CORE-BEG2007-PHASE_I-0.1.0") &
(julia -t5 --project scripts/BEG2007/PHASES_KOMA/7_shadow_price.jl -- "SIMVER:ECOLI-CORE-BEG2007-PHASE_II-0.1.0") &
(julia -t5 --project scripts/BEG2007/PHASES_KOMA/2.1_core_xlep0.jl -- "SIMVER:ECOLI-CORE-BEG2007-PHASE_I-0.1.0") &
(julia -t5 --project scripts/BEG2007/PHASES_KOMA/3.3_rxn_map.jl -- "SIMVER:ECOLI-CORE-BEG2007-PHASE_I-0.1.0") &
(julia -t5 --project scripts/BEG2007/PHASES_KOMA/3.2_gem_xlep0.jl -- "SIMVER:ECOLI-CORE-BEG2007-PHASE_I-0.1.0") &
(julia -t5 --project scripts/BEG2007/PHASES_KOMA/9_gem_biomass_fba.jl -- "SIMVER:ECOLI-CORE-BEG2007-PHASE_I-0.1.0") &
(julia -t5 --project scripts/BEG2007/PHASES_KOMA/9_biomass_fba.jl -- "SIMVER:ECOLI-CORE-BEG2007-PHASE_III-0.1.0") &
julia -t5 --project scripts/BEG2007/PHASES_KOMA/_summary.jl  --  "SIMVER:"
(julia -t5 --project scripts/BEG2007/PHASES_KOMA/6.2_plots.jl  --  "SIMVER:") &

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #
3142122 julia -t5 --project scripts/BEG2007/PHASES_KOMA/7_core_fva.jl -- SIMVER:ECOLI-CORE-BEG2007-PHASE_I-0.1.0
3160066 julia -t5 --project scripts/BEG2007/PHASES_KOMA/7_core_fva.jl -- SIMVER:ECOLI-CORE-BEG2007-PHASE_I-0.1.0

====================================
PROCS
3115123 julia -t5 --project scripts/BEG2007/CORE_PHASES_KOMA/7_fva.jl -- SIMVER:ECOLI-CORE-BEG2007-PHASE_II-0.1.0
3116370 julia -t5 --project scripts/BEG2007/CORE_PHASES_KOMA/7_fva.jl -- SIMVER:ECOLI-CORE-BEG2007-PHASE_III-0.1.0