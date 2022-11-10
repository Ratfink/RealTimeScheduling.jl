@testset "Weakly hard constraints" begin
    a = MeetAny(1, 5)
    b = MeetRow(2, 5)
    c = MissRow(3)
    d = MissRow(0)
    e = MeetRow(3, 5)
    f = MeetAny(4, 4)
    g = HardRealTime()
    h = MeetRow(0, 5)
    i = MeetAny(0, 3)
    j = BestEffort()
    @testset "Construction invariants" begin
        @test_throws DomainError MeetAny(-1, 5)
        @test_throws DomainError MeetAny(1, -1)
        @test_throws DomainError MeetAny(-1, -1)
        @test_throws DomainError MeetAny(6, 5)

        @test_throws DomainError MeetRow(-1, 5)
        @test_throws DomainError MeetRow(1, -1)
        @test_throws DomainError MeetRow(-1, -1)
        @test_throws DomainError MeetRow(6, 5)

        @test_throws DomainError MissRow(-1)
    end
    @testset "Properties" begin
        @test a.meet == 1
        @test a.window == 5
        @test b.meet == 2
        @test b.window == 5
        @test c.miss == 3
    end
    @testset "Equality" begin
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
    @testset "Satisfaction" begin
        bv = Matrix{BitVector}(undef, 1, 4)
        bv[1,1] = BitVector([0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1])
        bv[1,2] = BitVector([0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1])
        bv[1,3] = BitVector([0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1])
        bv[1,4] = BitVector([0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1])
        S = satisfies.(bv, [a;b;c;g;j])
        @test S == [1 1 1 0
                    1 0 0 0
                    1 1 0 0
                    0 0 0 0
                    1 1 1 1]
        S = bv .⊢ [a;b;c;g;j]
        @test S == [1 1 1 0
                    1 0 0 0
                    1 1 0 0
                    0 0 0 0
                    1 1 1 1]
        S = bv .⊬ [a;b;c;g;j]
        @test S == [0 0 0 1
                    0 1 1 1
                    0 0 1 1
                    1 1 1 1
                    0 0 0 0]
    end
    @testset "Random generation" begin
        # Test that all samples satisfy the constraint
        sp = SamplerUniformMissRow(c, 100)
        seqs = rand(sp, 1000)
        @test all(seqs .⊢ c)
    end
end
