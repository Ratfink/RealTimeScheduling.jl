@testset "Job-Class-Level Scheduling" begin
    using RealTimeScheduling.Papers.JobClassLevelScheduling

    # Example from 10.1109/JIOT.2021.3058215
    wh_ex = TaskSystem([PeriodicWeaklyHardTask(11, 11, 6, MissAny(2, 4)),
                        PeriodicWeaklyHardTask(7, 7, 4, MissAny(4, 7))])
    lifw = low_index_first(wh_ex)
    @test lifw == [[2, 4, 6], [1, 3, 5, 7]]
    @test schedulable_jcl(wh_ex, lifw)
    @test low_index_first_hold(wh_ex) == lifw
    s = schedule_jcl(wh_ex, 100, lifw)
    @test exectime.(s.jobs[1]) == [6, 6, 4, 6, 5, 6, 6, 6, 6, 0]
    @test exectime.(s.jobs[2]) == [4, 4, 1, 4, 4, 3, 4, 4, 2, 4, 4, 4, 1, 4, 2]
end
