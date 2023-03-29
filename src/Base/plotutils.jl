# ------------------------------------------------------------------
export _colormap
function _colormap(p::Vector{RGB{Float64}}, xmin, xmax, x)
    N = length(p)
    r = range(xmin, xmax; length = N)
    _, idx = findmin((y) -> abs(x - y), r)
    return p[idx]
end

function _colormap(xmin, xmax, x;
        cname = "Grays", 
        N = 1000, 
        mid=0.5, 
        logscale=false,
    )
    cm = Plots.colormap(cname, N; mid, logscale)
    i = max(1, div(N, 5)):N
    _colormap(cm[i], xmin, xmax, x)
end

## ------------------------------------------------------------------
# Trajectoreis
export _plot_bash1 
function _plot_bash1(netid, ep_alg_version;
        biom_lims = (0.0, 0.7), 
        m_glcs_lims = (0.0, 0.10)
    )
    traj_dir = procdir(NutrientLimitedGEMs, [netid, "sims"])
    p = plot()
    traj_lens, boxs = [], []
    biom1s, m_glcs = [], []
    @time for fn in readdir(traj_dir; join = true)
        endswith(fn, ".jls") || continue
        traj = ldat(fn)
        traj["status"] == :success || continue
        haskey(traj, ep_alg_version) || continue

        # traj_lens
        traj_idxs = traj["traj_idxs"]
        push!(traj_lens, length(traj_idxs))
        
        # box vol
        net = traj["net"]
        vol = prod(big.(net.ub .- net.lb))
        push!(boxs, vol)
        
        # biom
        biom1 = traj["biom1"]
        push!(biom1s, biom1)
        
        # glc_m
        _m_glcs = traj["m_glcs"]
        push!(m_glcs, last(_m_glcs))

    end

    ps = Plots.Plot[]

    c = _colormap.(biom_lims..., biom1s; cname = "Grays")
    scatter_args = (;label = "", msc = :auto, title = netid, ms = 8, c)

    boxs ./= maximum(boxs)
    p = scatter(traj_lens, log10.(boxs); 
        scatter_args...,
        xlabel = "ko steps", 
        ylabel = "propto box vol",
        xlim = (0, Inf),
    )
    push!(ps, p)
    
    p = scatter(traj_lens, biom1s; 
        scatter_args...,
        xlabel = "ko steps", 
        ylabel = "max biom", 
        xlim = (0, Inf),
        ylim = biom_lims
    )
    push!(ps, p)

    p = scatter(traj_lens, m_glcs; 
        scatter_args...,
        xlabel = "ko steps", 
        ylabel = "glc m", 
        xlim = (0, Inf),
        ylim = m_glcs_lims,
    )
    push!(ps, p)

    p = histogram(m_glcs;
        bins = 80,
        label = "", c = :black,
        title = netid,
        xlabel = "glc m", 
        ylabel = "count", 
    )
    push!(ps, p)

    p = scatter(biom1s, m_glcs; 
        scatter_args...,
        xlabel = "max biom", 
        ylabel = "glc m", 
        xlim = biom_lims,
        ylim = m_glcs_lims
    )

    push!(ps, p)
    p = scatter(biom1s, log10.(boxs); 
        scatter_args...,
        xlabel = "max biom", 
        ylabel = "propto box vol", 
        xlim = biom_lims
    )
    push!(ps, p)

    sfig(NutrientLimitedGEMs, ps, 
        netid, "trajectories", ep_alg_version, ".png"
    )

end

## ------------------------------------------------------------------
function _find_val_idxs(f::Function, v, vs...)
    val_idxs = Int[]
    for (i, vals) in enumerate(zip(v, vs...))
        any(iszero.(vals)) && continue
        any(isinf.(vals)) && continue
        any(isnan.(vals)) && continue
        f(vals) || continue
        push!(val_idxs, i)
    end
    return val_idxs
end
_find_val_idxs(v, vs...) = _find_val_idxs((vals) -> true, v, vs...)

# ------------------------------------------------------------------
# Entropy
export _plot_bash2
function _plot_bash2(netid, ep_alg_version;
        biom_lims
    )

    ps = Plots.Plot[]
    traj_dir = procdir(NutrientLimitedGEMs, [netid, "sims"])
    p_ΔS = plot(; xlabel = "ko steps", ylabel = "ΔS")
    p_ΔF = plot(; xlabel = "ko steps", ylabel = "ΔF")
    p_ΔV = plot(; xlabel = "ko steps", ylabel = "log vol box")
    p_log_ZQ = plot(; xlabel = "ko steps", ylabel = "log_ZQ")
    p_∑logZ_Qn = plot(; xlabel = "ko steps", ylabel = "∑logZ_Qn")
    last_val_idxs, biom1s, ΔS1s, ΔF1s, log_ZQ1s, ∑logZ_Qn1s, ΔV1s = [], [], [], [], [], [], []
    files = readdir(traj_dir; join = true)
    @time for fn in files
        endswith(fn, ".jls") || continue
        traj = ldat(fn)
        traj["status"] == :success || continue
        epdat = get(traj, ep_alg_version, nothing)
        isnothing(epdat) && continue

        
        # stuff
        Fs = epdat["Fs"]
        Ss = epdat["Ss"]
        Vs = epdat["box_vols"]
        log_ZQs = epdat["log_ZQs"]
        ∑logZ_Qns = epdat["∑logZ_Qns"]
        
        # ep_status1
        ep_statuses = epdat["ep_statuses"]

        # traj_idxs
        traj_idxs = traj["traj_idxs"]
        isempty(traj_idxs) && continue

        val_idxs1 = findall(ep_statuses .== :converged)
        val_idxs2 = _find_val_idxs(Ss, Fs, log_ZQs, ∑logZ_Qns)
        val_idxs = intersect(val_idxs1, val_idxs2)
        isempty(val_idxs) && continue

        # bioms
        biom1 = traj["biom1"]
        
        # Δs
        ΔFs = Fs[val_idxs] .- first(Fs[val_idxs])
        log_ZQs = log_ZQs[val_idxs] .- first(log_ZQs[val_idxs])
        ∑logZ_Qns = ∑logZ_Qns[val_idxs] .- first(∑logZ_Qns[val_idxs])
        ΔSs = Ss[val_idxs] .- first(Ss[val_idxs])
        ΔVs = Vs[val_idxs] ./ maximum(Vs[val_idxs])
        # any(ΔS .> 5.0) && continue
        
        # Plots
        c = _colormap(biom_lims..., biom1; cname = "Grays")
        plot!(p_ΔF, val_idxs, ΔFs; 
            label = "", c, lw = 2, alpha = 0.4, 
            ls = all(ep_statuses .== :converged) ? :solid : :dot
        )
        plot!(p_log_ZQ, val_idxs, log_ZQs; 
            label = "", c, lw = 2, alpha = 0.4, 
            ls = all(ep_statuses .== :converged) ? :solid : :dot
        )
        plot!(p_∑logZ_Qn, val_idxs, ∑logZ_Qns; 
            label = "", c, lw = 2, alpha = 0.4, 
            ls = all(ep_statuses .== :converged) ? :solid : :dot
        )
        plot!(p_ΔS, val_idxs, ΔSs; 
            label = "", c, lw = 2, alpha = 0.4, 
            ls = all(ep_statuses .== :converged) ? :solid : :dot
        )
        plot!(p_ΔV, val_idxs, log10.(ΔVs); 
            label = "", c, lw = 2, alpha = 0.4, 
            ls = all(ep_statuses .== :converged) ? :solid : :dot
        )

        push!(ΔF1s, last(ΔFs))
        push!(log_ZQ1s, last(log_ZQs))
        push!(∑logZ_Qn1s, last(∑logZ_Qns))
        push!(ΔS1s, last(ΔSs))
        push!(ΔV1s, last(ΔVs))
        push!(last_val_idxs, Int(last(val_idxs)))
        push!(biom1s, biom1)

    end

    c = _colormap.(biom_lims..., biom1s; cname = "Grays")
    scatter!(p_ΔF, last_val_idxs, ΔF1s; 
        label = "", c, m = 6, alpha = 0.8, 
        msc=:auto, xlim = (0, Inf)
    )
    push!(ps, p_ΔF)
    
    scatter!(p_log_ZQ, last_val_idxs, log_ZQ1s; 
        label = "", c, m = 6, alpha = 0.8, 
        msc=:auto, xlim = (0, Inf)
    )
    push!(ps, p_log_ZQ)

    scatter!(p_∑logZ_Qn, last_val_idxs, ∑logZ_Qn1s; 
        label = "", c, m = 6, alpha = 0.8, 
        msc=:auto, xlim = (0, Inf)
    )
    push!(ps, p_∑logZ_Qn)
    
    scatter!(p_ΔV, last_val_idxs, log10.(ΔV1s); 
        label = "", c, m = 6, alpha = 0.8,
        msc=:auto, xlim = (0, Inf),
    )
    push!(ps, p_ΔV)

    scatter!(p_ΔS, last_val_idxs, ΔS1s; 
        label = "", c, m = 6, alpha = 0.8, 
        msc=:auto, xlim = (0, Inf)
    )
    push!(ps, p_ΔS)

    # p_biom1s_ΔF1s = scatter(biom1s, ΔF1s; 
    #     label = "", c, m = 6, alpha = 0.8,
    #     xlabel = "max biom", ylabel = "ΔF", 
    #     msc=:auto, xlim = biom_lims
    # )
    # push!(ps, p_biom1s_ΔF1s)

    # p_biom1s_ΔS1s = scatter(biom1s, ΔS1s; 
    #     label = "", c, m = 6, alpha = 0.8,
    #     xlabel = "max biom", ylabel = "ΔS", 
    #     msc=:auto, xlim = biom_lims
    # )
    # push!(ps, p_biom1s_ΔS1s)
    
    # p_biom1s_ΔV1s = scatter(biom1s, log.(ΔV1s); 
    #     label = "", c, m = 6, alpha = 0.8,
    #     xlabel = "max biom", ylabel = "log vol box", 
    #     msc=:auto, xlim = biom_lims
    # )
    # push!(ps, p_biom1s_ΔV1s)

    p_ΔS1s_ΔF1s = scatter(ΔS1s, log.(ΔF1s); 
        label = "", c, m = 6, alpha = 0.8,
        xlabel = "ΔS", ylabel = "log ΔF", 
        msc=:auto
    )
    push!(ps, p_ΔS1s_ΔF1s)

    p_ΔS1s_log_ZQ1s = scatter(ΔS1s, log_ZQ1s; 
        label = "", c, m = 6, alpha = 0.8,
        xlabel = "ΔS", ylabel = "log_ZQ", 
        msc=:auto
    )
    
    push!(ps, p_ΔS1s_log_ZQ1s)
    p_ΔS1s_∑logZ_Qn1s = scatter(ΔS1s, ∑logZ_Qn1s; 
        label = "", c, m = 6, alpha = 0.8,
        xlabel = "normalized ΔS", ylabel = "normalized ∑logZ_Qn", 
        msc=:auto
    )
    push!(ps, p_ΔS1s_∑logZ_Qn1s)

    p_ΔS1s_ΔV1s = scatter(ΔS1s, log.(ΔV1s); 
        label = "", c, m = 6, alpha = 0.8,
        xlabel = "ΔS", ylabel = "log vol box", 
        msc=:auto
    )
    push!(ps, p_ΔS1s_ΔV1s)

    p_ΔF1s_ΔV1s = scatter(ΔF1s, log.(ΔV1s); 
        label = "", c, m = 6, alpha = 0.8,
        xlabel = "ΔF", ylabel = "log vol box", 
        msc=:auto
    )
    push!(ps, p_ΔF1s_ΔV1s)

    # p_last_val_idxs_biom1s = scatter(last_val_idxs, biom1s; 
    #     label = "", c, m = 6, alpha = 0.8,
    #     xlabel = "ok steps", ylabel = "max biom", 
    #     msc=:auto, 
    #     xlim = (0, Inf),
    #     ylim = biom_lims
    # )
    # push!(ps, p_last_val_idxs_biom1s)

    # write
    sfig(NutrientLimitedGEMs, ps, 
        netid, "entropy", ep_alg_version, ".png";
        layout = (2, 5)
    )
end