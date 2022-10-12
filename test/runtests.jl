using RealTimeScheduling
using Test

@testset "RealTimeScheduling.jl" begin
    @testset "PeriodicTask" begin
        @test_throws TypeError PeriodicTask{ComplexF64}(4, 3, 2)
        τ_1 = PeriodicTask{Int64}(4, 3, 2)
        @test period(τ_1) == 4
        @test deadline(τ_1) == 3
        @test cost(τ_1) == 2
        @test utilization(τ_1) == 2//4
        @test utilization(τ_1) isa Rational{Int64}
        @test density(τ_1) == 2//3
        @test density(τ_1) isa Rational{Int64}
        @test !implicit_deadline(τ_1)
        @test constrained_deadline(τ_1)
        @test feasible(τ_1)
        @test [demand_bound(τ_1, t) for t in -2:8] == [0, 0, 0, 0, 0, 2, 2, 2, 2, 4, 4]
        @test [request_bound(τ_1, t) for t in -2:8] == [0, 0, 2, 2, 2, 2, 4, 4, 4, 4, 6]
        τ_2 = PeriodicTask{Int64}(4, 4, 8)
        @test implicit_deadline(τ_2)
        @test constrained_deadline(τ_2)
        @test !feasible(τ_2)
        τ_3 = PeriodicTask{Int64}(4, 6, 2)
        @test !implicit_deadline(τ_3)
        @test !constrained_deadline(τ_3)
        τ_f1 = PeriodicTask{Float64}(4, 3, 2)
        @test utilization(τ_f1) == 0.5
        @test utilization(τ_f1) isa Float64
        @test density(τ_f1) ≈ 2/3  # Should be exactly equal, but I don't trust FPUs
        @test density(τ_f1) isa Float64
    end
end
