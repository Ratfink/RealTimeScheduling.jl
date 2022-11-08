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
