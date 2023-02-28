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
    @test responsetime.(s.jobs[1]) == [2, 2, 2]
    @test responsetime.(s.jobs[2][1:2]) == [4, 4]
    @test_throws ArgumentError responsetime(s.jobs[2][3])
    @test responsetime.(s.jobs[3]) == [2, 3, 3]

    # Example from 10.1109/JIOT.2021.3058215
    wh_ex = TaskSystem([PeriodicWeaklyHardTask(11, 11, 6, MissAny(2, 4)),
                        PeriodicWeaklyHardTask(7, 7, 4, MissAny(4, 7))])
    s = schedule_gfp(wh_ex, 1, 77, kill=true)
    @test all(exectime.(s.jobs[1]) .== 6)
    @test exectime.(s.jobs[2]) == [1, 4, 4, 1, 4, 3, 2, 4, 2, 3, 4]
    rate_monotonic!(wh_ex)
    s = schedule_gfp(wh_ex, 1, 77, kill=true)
    @test all(exectime.(s.jobs[1]) .== 4)
    @test exectime.(s.jobs[2]) == [3, 6, 4, 5, 5, 4, 6]
end
