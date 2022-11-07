using RealTimeScheduling
using Test

@testset "RealTimeScheduling.jl" begin
    τ_1 = PeriodicTask{Int64}(4, 3, 2)
    τ_f1 = PeriodicTask{Float64}(4, 3, 2)
    τ_2 = PeriodicTask{Int64}(4, 4, 8)
    τ_3 = PeriodicTask{Int64}(4, 6, 2)
    τ_4 = PeriodicImplicitTask{Int64}(5, 2)
    τ_f4 = PeriodicImplicitTask{Float64}(5, 2)
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
        @test [demand_bound(τ_1, t) for t in -2:8] == [0, 0, 0, 0, 0, 2, 2, 2, 2, 4, 4]
        @test [request_bound(τ_1, t) for t in -2:8] == [0, 0, 0, 2, 2, 2, 2, 4, 4, 4, 4]

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

    @testset "Schedulability tests" begin
        # Test the utilization bound
        T = TaskSystem([PeriodicImplicitTask(5, 1), PeriodicImplicitTask(6, 2), PeriodicImplicitTask(8, 1)])
        @test schedulable_fixed_priority(T)
        T[1] = PeriodicImplicitTask(5, 3)
        @test !schedulable_fixed_priority(T)
        # Test simple TDA
        T[1] = PeriodicImplicitTask(4, 2)
        @test !schedulable_fixed_priority(T)
        T[1] = PeriodicImplicitTask(2, 1)
        @test schedulable_fixed_priority(T)
        # Test general TDA
        lehoczky = TaskSystem([PeriodicTask(70, 70, 26), PeriodicTask(100, 118, 62)])
        @test schedulable_fixed_priority(lehoczky)
        lehoczky[2] = PeriodicTask(100, 116, 62)
        @test !schedulable_fixed_priority(lehoczky)
    end

    @testset "Weakly hard constraints" begin
        # Construction
        @test_throws DomainError MeetAny(-1, 5)
        @test_throws DomainError MeetAny(1, -1)
        @test_throws DomainError MeetAny(-1, -1)
        @test_throws DomainError MeetAny(6, 5)
        a = MeetAny(1, 5)
        @test a.meet == 1
        @test a.window == 5
        @test_throws DomainError MeetRow(-1, 5)
        @test_throws DomainError MeetRow(1, -1)
        @test_throws DomainError MeetRow(-1, -1)
        @test_throws DomainError MeetRow(6, 5)
        b = MeetRow(1, 5)
        @test b.meet == 1
        @test b.window == 5
        @test_throws DomainError MissRow(-1)
        c = MissRow(3)
        @test c.miss == 3
        # Equality
        d = MissRow(0)
        e = MeetRow(3, 5)
        f = MeetAny(4, 4)
        g = HardRealTime()
        h = MeetRow(0, 5)
        i = MeetAny(0, 3)
        j = BestEffort()
        C = [a b c d e f g h i j] .== [a;b;c;d;e;f;g;h;i;j]
        @test C == [1 0 0 0 0 0 0 0 0 0
                    0 1 0 0 0 0 0 0 0 0
                    0 0 1 0 0 0 0 0 0 0
                    0 0 0 1 1 1 1 0 0 0
                    0 0 0 1 1 1 1 0 0 0
                    0 0 0 1 1 1 1 0 0 0
                    0 0 0 1 1 1 1 0 0 0
                    0 0 0 0 0 0 0 1 1 1
                    0 0 0 0 0 0 0 1 1 1
                    0 0 0 0 0 0 0 1 1 1]
    end
end
