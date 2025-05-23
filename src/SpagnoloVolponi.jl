# insert here your directory # cd()

using DataFrames, StatFiles, CSV, Statistics, Plots, StatsPlots

pwd()

md"""# Table 1"""

begin
	violence_df = CSV.read("origmun_violence_commodities.csv", DataFrame)

	wages_df = CSV.read("origmun_wages_commodities.csv", DataFrame)

	hours_df = CSV.read("origmun_hours_commodities.csv", DataFrame)

	migrant_df = CSV.read("origmun_migrant_commodities.csv", DataFrame)
end


function summarize(df::DataFrame, vars::Vector{Symbol})
    result = DataFrame(Variable = Symbol[], Obs = Int[], Mean = Float64[],
                       Median = Float64[], StdDev = Float64[], Min = Float64[], Max = Float64[])
    
    for v in vars
        col = collect(skipmissing(df[!, v]))
        if !isempty(col)
            push!(result, (
                v,  # mantieni come Symbol
                length(col),
                mean(col),
                median(col),
                std(col),
                minimum(col),
                maximum(col)
            ))
        end
    end

    # Converti i simboli in stringa se serve per stampa/esportazione
    result.Variable = string.(result.Variable)

    return result
end


begin
	panel_vars = [:gueratt, :paratt, :clashes, :casualties, :govatt, :parmass, :guermass, :guerkidpol, :parkidpol, :lpop, :lcaprev, :coca]
	
	municipal_vars = [:cofint, :oilprod88, :coalprod04, :coalres78, :goldprod04, :mining78, :coca94ind, :coca94, :evercoca, :rainfall, :temperature, :yrspropara]
	
	annual_vars = [:linternalp, :lop, :lcoalp, :lgoldp, :lsilverp, :lplatp, :ltop3cof, :ltop3coal]
end


begin
	panel_stats = summarize(violence_df, panel_vars)
	municipal_stats = summarize(filter(:year => ==(1996), violence_df), municipal_vars)
	annual_stats = summarize(filter(:origmun => ==(5002), violence_df), annual_vars)
	wage_stats = summarize(wages_df, [:lwage])
	hours_stats = summarize(hours_df, [:lhours])
	migrant_stats = summarize(migrant_df, [:migrant])
end


function section_row(title::String)
    return DataFrame(Variable = [title], Obs = [missing], Mean = [missing],
                     Median = [missing], StdDev = [missing], Min = [missing], Max = [missing])
end


final_summary = vcat(
    section_row("Panel-level variables"),
    panel_stats,
    section_row("Municipal-level variables"),
    municipal_stats,
    section_row("Annual-level variables"),
    annual_stats,
    section_row("Individual-level variables"),
    wage_stats,
    hours_stats,
    migrant_stats
)


# CSV.write("summary_stats.csv", final_summary)


md"""# Figure 3"""


begin
	vars_fig_3 = [:gueratt, :paratt, :clashes, :casualties]
	annual_means = combine(groupby(violence_df, :year), 
    [:gueratt => mean => :guerilla_attacks,
     :paratt => mean => :paramilitary_attacks,
     :clashes => mean => :clashes,
     :casualties => mean => :casualties]
)
	sort!(annual_means, :year)
end


begin

	xticks_f3 = (1988:1:2005, string.(1988:1:2005))
    xrotation_f3 = 90
    layout_f3 = @layout [a b; c d]
	p1_f3 = plot(annual_means.year, annual_means.guerilla_attacks,
    title="Guerrilla attacks", ylabel = "Number attacks", xlabel = "", xticks = xticks_f3, xrotation = xrotation_f3, legend=false, lw=2, ylim=(0,1))

	p2_f3 = plot(annual_means.year, annual_means.paramilitary_attacks,
    title="Paramilitary attacks", ylabel = "Number attacks", xlabel = "", xticks = xticks_f3, xrotation = xrotation_f3, legend=false, lw=2, ylim=(0,0.25))

	p3_f3 = plot(annual_means.year, annual_means.clashes,
    title="Clashes", ylabel = "Number clashes", xlabel = "", xticks = xticks_f3, xrotation = xrotation_f3, legend=false, lw=2, ylim=(0,1))

	p4_f3 = plot(annual_means.year, annual_means.casualties,
    title="Casualties", ylabel = "Number casualties", xlabel = "", xticks = xticks_f3, xrotation = xrotation_f3, legend=false, lw=2, ylim=(0,4))

	fig_3 = plot(p1_f3, p2_f3, p3_f3, p4_f3, layout = layout_f3, size=(800, 600), titlefontsize=10)

end


md"""# Figure 4"""


begin
	df_no_missing = dropmissing(violence_df, [:year, :cofint])
	coffee_mun_ids = unique(df_no_missing[df_no_missing.year .== 1997 .&& df_no_missing.cofint .> 0, :origmun])
	violence_df.coffee_mun = in.(violence_df.origmun, Ref(coffee_mun_ids))
end


grouped = combine(groupby(violence_df, [:year, :coffee_mun]), 
    :gueratt => mean, 
    :paratt => mean,
    :clashes => mean,
    :casualties => mean)


coffee_price = combine(groupby(violence_df, :year), :linternalp => mean => :coffee_price)


df_plot = leftjoin(grouped, coffee_price, on=:year)

begin
	coffee_df = df_plot[df_plot.coffee_mun .== true, :]
	noncoffee_df = df_plot[df_plot.coffee_mun .== false, :]
end


using Measures; gr()

function plot_dual(y1_nc, y1_c, y2, title, ylabel1; ylim1=nothing, ylim2=nothing)
    # Primo asse Y (violenza)
	years_fig_4 = 1988:2005
    p = plot(noncoffee_df.year, y1_nc,
        label="Non-coffee mun", linestyle=:dash, color=:black,
        xlabel="Year", ylabel=ylabel1, legend=:topleft, xticks=years_fig_4,
		xrotation=90, ylim=ylim1, left_margin=10mm)

	plot!(p, coffee_df.year, y1_c,
        label="Coffee mun", linestyle=:solid, linewidth = 2, color=:black)

    # Secondo asse Y (coffee price) – asse destro
    p2 = twinx(p)
    plot!(p2, coffee_df.year, y2,
        label="Coffee price", color=:grey, linewidth=2,
        ylabel="Coffee price", ylim=ylim2, right_margin=14mm)

    plot!(title=title, xlim=(1988,2005))
    return p
end


begin
	p1 = plot_dual(noncoffee_df.gueratt_mean, coffee_df.gueratt_mean, coffee_df.coffee_price, "Guerrilla attacks", "Number of attacks", ylim1=(0,1.2), ylim2=(0, 2.0))

	p2 = plot_dual(noncoffee_df.paratt_mean, coffee_df.paratt_mean, coffee_df.coffee_price, "Paramilitary attacks", "Number of attacks", ylim1=(0, 0.3), ylim2=(0, 2.0))

	p3 = plot_dual(noncoffee_df.clashes_mean, coffee_df.clashes_mean, coffee_df.coffee_price, "Clashes", "Number of attacks", ylim1=(0, 1.0), ylim2=(0, 2.0))

	p4 = plot_dual(noncoffee_df.casualties_mean, coffee_df.casualties_mean, coffee_df.coffee_price, "Casualties", "Number of casualties", ylim1=(0, 4.5), ylim2=(0, 2.0))

	fig_4 = plot(p1, p2, p3, p4, layout=(2,2), size=(1200,800))
end


md"""# Figure 5"""


violence_df.oil_mun = violence_df.oilprod88 .> 0

# Aggrega media annuale per tipo di municipio
oil_grouped = combine(groupby(violence_df, [:year, :oil_mun]), 
    :gueratt => mean,
    :paratt => mean,
    :clashes => mean,
    :casualties => mean)


# Calcola media del prezzo log del petrolio per anno
oil_price = combine(groupby(violence_df, :year), :lop => mean => :oil_price)


# Unisci i due set
df_plot_oil = leftjoin(oil_grouped, oil_price, on=:year)


# Split oil / non-oil
begin
	oil_df = df_plot_oil[df_plot_oil.oil_mun .== true, :]	
	nonoil_df = df_plot_oil[df_plot_oil.oil_mun .== false, :]
end


function plot_dual_oil(y1_nonoil, y1_oil, y2, title, ylabel1; ylim1=nothing, ylim2=nothing, yticks1=nothing, yticks2=nothing)
    # Anni da mostrare
    years_fig_5 = 1988:2005

    # Primo asse Y (violenza)
    p = plot(nonoil_df.year, y1_nonoil,
        label="Non-oil mun", linestyle=:dash, color=:black,
        xlabel="Year", ylabel=ylabel1,
        legend=:top, xticks=years_fig_5, xrotation=90,
        ylim=ylim1, yticks=yticks1, left_margin=10mm)

    # Municipi oil
    plot!(p, oil_df.year, y1_oil,
        label="Oil mun", color=:black, linewidth=2)

    # Secondo asse Y (prezzo del petrolio)
    p2 = twinx(p)
    plot!(p2, oil_df.year, y2,
        label="Oil price", color=:grey, linewidth=2, ylabel="Oil price", ylim=ylim2, yticks=yticks2, right_margin=14mm)

    # Titolo e limiti
    plot!(title=title, xlim=(1988,2005))

    return p
end



begin
	p_1_fig_5 = plot_dual_oil(nonoil_df.gueratt_mean, oil_df.gueratt_mean, oil_df.oil_price, "Guerrilla attacks", "Number of attacks", ylim1=(0,4), yticks1=0:0.5:4, ylim2=(2,5), yticks2=2:0.5:5)

	p_2_fig_5 = plot_dual_oil(
    nonoil_df.paratt_mean,
    oil_df.paratt_mean,
    oil_df.oil_price,
    "Paramilitary attacks",
    "Number of attacks";
    ylim1=(0, 0.7), yticks1=0:0.1:0.7,
    ylim2=(2, 5), yticks2=2:0.5:5
)
	p_3_fig_5 = plot_dual_oil(
    nonoil_df.clashes_mean,
    oil_df.clashes_mean,
    oil_df.oil_price,
    "Clashes",
    "Number clashes";
    ylim1=(0, 3), yticks1=0:0.5:3,
    ylim2=(2, 5), yticks2=2:0.5:5
)
	p_4_fig_5 = plot_dual_oil(
    nonoil_df.casualties_mean,
    oil_df.casualties_mean,
    oil_df.oil_price,
    "Casualties",
    "Number casualties";
    ylim1=(0, 12), yticks1=0:2:12,
    ylim2=(2, 5), yticks2=2:0.5:5
)
	fig_5 = plot(p_1_fig_5, p_2_fig_5, p_3_fig_5, p_4_fig_5, layout=(2,2), size=(1200,800))
end



md"""# Table 2"""


using FixedEffectModels, StatsModels, CausalInference, GLM


begin
    violence_df.cofintxlinternalp = violence_df.cofint .* violence_df.linternalp              # variabile endogena
    violence_df.instrument1 = violence_df.rxltop3cof                                 # primo strumento
    violence_df.instrument2 = violence_df.txltop3cof                                 # secondo strumento
    violence_df.instrument3 = violence_df.rtxltop3cof                                # terzo strumento
end


names(violence_df)


subset = dropmissing(violence_df, [
    :cofintxlinternalp, :instrument1, :instrument2, :instrument3,
    :oilprod88xlop, :lpop, :coca94indxyear,
    :gueratt, :paratt, :clashes, :casualties,
    :origmun, :year, :department
])


outcomes = [:gueratt, :paratt, :clashes, :casualties]


using RDatasets

using RegressionTables


function build_formula(depvar::Symbol)
    return @eval @formula($depvar ~ 1 +
        (cofintxlinternalp ~ instrument1 + instrument2 + instrument3) +
        oilprod88xlop + lpop + coca94indxyear +
        _RregXyear_2 + _RregXyear_3 + _RregXyear_4 +
        fe(origmun) + fe(year) + fe(region))
end


results_guerratt = (reg(violence_df, build_formula(:gueratt), Vcov.cluster(:department)))


results_paratt = (reg(violence_df, build_formula(:paratt), Vcov.cluster(:department)))


results_clashes = (reg(violence_df, build_formula(:clashes), Vcov.cluster(:department)))

results_casualties = (reg(violence_df, build_formula(:casualties), Vcov.cluster(:department)))


md"""# Table 3"""


formula_wages = @formula(lwage ~ gender + age + agesq + married + edyrs + 
                    oilprod88xlop +
                   (cofintxlinternalp ~ rxltop3cof + txltop3cof + rtxltop3cof) +
                   fe(region) + fe(year) + fe(origmun))


results_log_wages = reg(wages_df, formula_wages, Vcov.cluster(:department); weights = :pweight)


formula_hours = @formula(lhours ~ gender + age + agesq + married + edyrs + 
                    oilprod88xlop +
                   (cofintxlinternalp ~ rxltop3cof + txltop3cof + rtxltop3cof) +
                   fe(region) + fe(year) + fe(origmun))


results_log_hours = reg(hours_df, formula_hours, Vcov.cluster(:department); weights = :pweight)


results_lcaprev = (reg(violence_df, build_formula(:lcaprev), Vcov.cluster(:department)))

results_parkidpol = (reg(violence_df, build_formula(:parkidpol), Vcov.cluster(:department)))

results_guerkidpol = (reg(violence_df, build_formula(:guerkidpol), Vcov.cluster(:department)))

md"""# Table 6"""


function build_formula_table_6(depvar::Symbol)
    return @eval @formula($depvar ~ 1 +
        (coalprod04xlcoalp + goldprod04xlgoldp ~ coalres78xltop3coal + mining78xlgoldp) +
        oilprod88xlop + lpop + coca94indxyear + mining78xlsilverp + mining78xlplatp +
        _RregXyear_2 + _RregXyear_3 + _RregXyear_4 +
        fe(origmun) + fe(year) + fe(region))
end


results_1 = (reg(violence_df, build_formula_table_6(:gueratt), Vcov.cluster(:department)))

results_2 = (reg(violence_df, build_formula_table_6(:paratt), Vcov.cluster(:department)))

results_3 = (reg(violence_df, build_formula_table_6(:clashes), Vcov.cluster(:department)))

results_4 = (reg(violence_df, build_formula_table_6(:casualties), Vcov.cluster(:department)))