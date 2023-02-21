@testset "Scheduling algorithms" begin
    two_thirds_cubed = TaskSystem([PeriodicImplicitTask(3, 2),
                                   PeriodicImplicitTask(3, 2),
                                   PeriodicImplicitTask(3, 2)])
    s = schedule_gedf(two_thirds_cubed, 2, 9)
    @test all(exectime.(s.jobs[1]) .== 2)
    @test exectime.(s.jobs[2]) == [2, 2, 1]
    @test all(exectime.(s.jobs[3]) .== 2)
    @test completiontime.(s.jobs[1]) == [2, 5, 8]
    @test completiontime.(s.jobs[2][1:2]) == [4, 7]
    @test_throws ArgumentError completiontime(s.jobs[2][3])
    @test completiontime.(s.jobs[3]) == [2, 6, 9]
end
