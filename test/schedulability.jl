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
