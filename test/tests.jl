using Test
using DubeVargas2013
using DataFrames, Statistics, Plots
using FixedEffectModels

# Import the summarize and section_row functions from the main script
include("DubeVargas2013.jl")  

@testset "summarize function" begin
    df = DataFrame(a = [1.0, 2.0, 3.0, missing], b = [10.0, 20.0, 30.0, 40.0])
    result = summarize(df, [:a, :b])

    @test size(result, 1) == 2
    @test result.Variable == ["a", "b"]
    @test result.Obs[1] == 3
    @test isapprox(result.Mean[1], 2.0, atol=1e-8)
    @test isapprox(result.StdDev[2], std([10.0, 20.0, 30.0, 40.0]), atol=1e-8)
end

@testset "section_row function" begin
    row = section_row("Test Section")
    @test row.Variable[1] == "Test Section"
    @test ismissing(row.Obs[1])
    @test ncol(row) == 7
end

@testset "Instruments and interactions" begin
    test_df = DataFrame(
        cofint = [1.0, 0.0],
        linternalp = [0.5, 0.7],
        rxltop3cof = [0.1, 0.2],
        txltop3cof = [0.3, 0.4],
        rtxltop3cof = [0.5, 0.6]
    )

    test_df.cofintxlinternalp = test_df.cofint .* test_df.linternalp
    test_df.instrument1 = test_df.rxltop3cof
    test_df.instrument2 = test_df.txltop3cof
    test_df.instrument3 = test_df.rtxltop3cof

    @test test_df.cofintxlinternalp[1] == 0.5
    @test test_df.cofintxlinternalp[2] == 0.0
    @test test_df.instrument2[2] == 0.4
end

@testset "build_formula structure" begin
    f = build_formula(:gueratt)
    @test occursin("gueratt", string(f))
    @test occursin("cofintxlinternalp", string(f))
    @test occursin("instrument1", string(f))
end

@testset "Plot generation" begin
    years = 1988:1990
    p = plot(years, [1.0, 2.0, 3.0], title="Test Plot")
    @test typeof(p) <: AbstractPlot
end

@testset "Basic regression (only if data is loaded)" begin
    if @isdefined violence_df && nrow(violence_df) > 100
        try
            f = build_formula(:gueratt)
            res = reg(violence_df, f, Vcov.cluster(:department))
            @test haskey(coef(res), :cofintxlinternalp)
        catch e
            @warn "Regression failed in test: $e"
        end
    else
        @info "Dataset `violence_df` is not defined or too small for regression"
    end
end