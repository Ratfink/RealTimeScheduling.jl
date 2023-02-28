@testset "Response time analysis" begin
    two_thirds_cubed = TaskSystem([PeriodicImplicitTask(3, 2),
                                   PeriodicImplicitTask(3, 2),
                                   PeriodicImplicitTask(3, 2)])
    tardiness_bounds = tardiness_gedf(two_thirds_cubed, 2, GEDFDeviAnderson)
    resptime_bounds = response_time_gedf(two_thirds_cubed, 2, GEDFDeviAnderson)
    @test tardiness_bounds == [2.0, 2.0, 2.0]
    @test resptime_bounds == [5.0, 5.0, 5.0]
    tardiness_bounds = tardiness_gedf(two_thirds_cubed, 2, GEDFCompliantVector)
    resptime_bounds = response_time_gedf(two_thirds_cubed, 2, GEDFCompliantVector)
    @test tardiness_bounds == [2.0, 2.0, 2.0]
    @test resptime_bounds == [5.0, 5.0, 5.0]
end
