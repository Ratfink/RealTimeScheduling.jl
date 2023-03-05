@testset "Tasks and Task Systems" begin
    τ_1 = PeriodicTask{Int64}(4, 3, 2)
    τ_f1 = PeriodicTask{Float64}(4, 3, 2)
    τ_2 = PeriodicTask{Int64}(4, 4, 8)
    τ_3 = PeriodicTask{Int64}(4, 6, 2)
    τ_4 = PeriodicImplicitTask{Int64}(5, 2)
    τ_f4 = PeriodicImplicitTask{Float64}(5, 2)
    τ_5 = PeriodicTask{Int64}(5, 3, 2)
    τ_f5 = PeriodicTask{Float64}(5, 3, 2)
    τ_wh1 = PeriodicWeaklyHardTask(5, 3, 2, MeetAny(3, 5))
    τ_whf1 = PeriodicWeaklyHardTask(5., 3., 2., MeetAny(3, 5))
    τ_wh1e = PeriodicWeaklyHardTask(τ_5, MeetAny(3, 5))
    τ_whf1e = PeriodicWeaklyHardTask(τ_f5, MeetAny(3, 5))
    τ_wh2 = PeriodicWeaklyHardTask(5, 3, 2, MeetAny(0, 0))
    τ_whf2 = PeriodicWeaklyHardTask(5., 3., 2., MeetAny(0, 0))
    τ_wh3 = PeriodicWeaklyHardTask(5, 3, 2, MeetRow(0, 0))
    τ_whf3 = PeriodicWeaklyHardTask(5., 3., 2., MeetRow(0, 0))
    τ_wh4 = PeriodicWeaklyHardTask(5, 3, 2, MeetRow(0, 4))
    τ_whf4 = PeriodicWeaklyHardTask(5., 3., 2., MeetRow(0, 4))
    @testset "PeriodicTask" begin
        @test_throws TypeError PeriodicTask{ComplexF64}(4, 3, 2)
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
        @test demand_bound.(τ_1, -2:8) == [0, 0, 0, 0, 0, 2, 2, 2, 2, 4, 4]
        @test request_bound.(τ_1, -2:8) == [0, 0, 0, 2, 2, 2, 2, 4, 4, 4, 4]

        @test implicit_deadline(τ_2)
        @test constrained_deadline(τ_2)
        @test !feasible(τ_2)

        @test !implicit_deadline(τ_3)
        @test !constrained_deadline(τ_3)

        @test utilization(τ_f1) == 0.5
        @test utilization(τ_f1) isa Float64
        @test density(τ_f1) ≈ 2/3  # Should be exactly equal, but I don't trust FPUs
        @test density(τ_f1) isa Float64
    end
    @testset "PeriodicImplicitTask" begin
        @test_throws TypeError PeriodicImplicitTask{ComplexF64}(4, 2)
        @test period(τ_4) == 5
        @test deadline(τ_4) == 5
        @test cost(τ_4) == 2
        @test utilization(τ_4) == 2//5
        @test utilization(τ_4) isa Rational{Int64}
        @test density(τ_4) == 2//5
        @test density(τ_4) isa Rational{Int64}
        @test implicit_deadline(τ_4)
        @test constrained_deadline(τ_4)
        @test feasible(τ_4)

        @test utilization(τ_f4) ≈ 0.4
        @test utilization(τ_f4) isa Float64
        @test density(τ_f4) ≈ 0.4
        @test density(τ_f4) isa Float64
    end
    @testset "PeriodicWeaklyHardTask" begin
        @test period(τ_wh1) == 5
        @test deadline(τ_wh1) == 3
        @test cost(τ_wh1) == 2
        @test constraint(τ_wh1) == MeetAny(3, 5)
        @test min_utilization(τ_wh1) isa Rational{Int64}
        @test min_utilization(τ_wh1) == 6//25
        @test min_density(τ_wh1) isa Rational{Int64}
        @test min_density(τ_wh1) == 6//15
        @test min_utilization(τ_wh2) isa Rational{Int64}
        @test min_utilization(τ_wh2) == 0
        @test min_density(τ_wh2) isa Rational{Int64}
        @test min_density(τ_wh2) == 0
        @test min_utilization(τ_wh3) isa Rational{Int64}
        @test min_utilization(τ_wh3) == 0
        @test min_density(τ_wh3) isa Rational{Int64}
        @test min_density(τ_wh3) == 0
        @test min_utilization(τ_wh4) isa Rational{Int64}
        @test min_utilization(τ_wh4) == 0
        @test min_density(τ_wh4) isa Rational{Int64}
        @test min_density(τ_wh4) == 0

        @test min_utilization(τ_whf1) isa Float64
        @test min_utilization(τ_whf1) ≈ 0.24
        @test min_density(τ_whf1) isa Float64
        @test min_density(τ_whf1) ≈ 0.4
        @test min_utilization(τ_whf2) isa Float64
        @test min_utilization(τ_whf2) == 0.0
        @test min_density(τ_whf2) isa Float64
        @test min_density(τ_whf2) == 0.0
        @test min_utilization(τ_whf3) isa Float64
        @test min_utilization(τ_whf3) == 0.0
        @test min_density(τ_whf3) isa Float64
        @test min_density(τ_whf3) == 0.0
        @test min_utilization(τ_whf4) isa Float64
        @test min_utilization(τ_whf4) == 0.0
        @test min_density(τ_whf4) isa Float64
        @test min_density(τ_whf4) == 0.0

        @test τ_wh1 == τ_wh1e
        @test τ_whf1 == τ_whf1e
    end
    @testset "Periodic[Implicit]Task conversion" begin
        @test convert(PeriodicTask{Float64}, τ_1) == τ_f1
        @test convert(PeriodicTask{Float64}, τ_1) isa PeriodicTask{Float64}
        @test convert(PeriodicImplicitTask{Float64}, τ_4) == τ_f4
        @test convert(PeriodicImplicitTask{Float64}, τ_4) isa PeriodicImplicitTask{Float64}
        @test convert(PeriodicTask{Int64}, τ_4) == PeriodicTask{Int64}(5, 5, 2)
        @test convert(PeriodicTask{Int64}, τ_4) isa PeriodicTask{Int64}
        @test convert(PeriodicTask{Float64}, τ_4) == PeriodicTask{Float64}(5, 5, 2)
        @test convert(PeriodicTask{Float64}, τ_4) isa PeriodicTask{Float64}
        @test convert(PeriodicTask{Float64}, τ_f4) == PeriodicTask{Float64}(5, 5, 2)
        @test convert(PeriodicTask{Float64}, τ_f4) isa PeriodicTask{Float64}
    end
    @testset "Periodic[Implicit]Task promotion" begin
        @test eltype([τ_1, τ_f1]) == PeriodicTask{Float64}
        @test eltype([τ_4, τ_f4]) == PeriodicImplicitTask{Float64}

        @test eltype([τ_1, τ_4]) == PeriodicTask{Int64}
        @test eltype([τ_f1, τ_f4]) == PeriodicTask{Float64}
        @test eltype([τ_1, τ_f4]) == PeriodicTask{Float64}
        @test eltype([τ_f1, τ_4]) == PeriodicTask{Float64}
    end
end
