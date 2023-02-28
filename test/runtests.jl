using RealTimeScheduling
using Test

@testset "RealTimeScheduling.jl" begin
    include("tasks.jl")

    include("schedulability.jl")

    include("responsetime.jl")

    include("schedules.jl")

    include("weaklyhard.jl")

    include("papers/Papers.jl")
end
