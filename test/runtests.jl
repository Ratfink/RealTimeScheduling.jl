using RealTimeScheduling
using Test

@testset "RealTimeScheduling.jl" begin
    include("tasks.jl")

    include("schedulability.jl")

    include("weaklyhard.jl")
end
