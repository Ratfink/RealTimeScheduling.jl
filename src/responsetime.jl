abstract type GEDFAlgorithm end

struct GEDFDeviAndersonAlg <: GEDFAlgorithm end

"""
    GEDFDeviAnderson

Indicate that a response time bound should be computed according to Devi and Anderson,
"Tardiness Bounds under Global EDF Scheduling on a Multiprocessor."
DOI: https://doi.org/10.1007/s11241-007-9042-1
"""
const GEDFDeviAnderson = GEDFDeviAndersonAlg()

"""
    response_time_gedf(T, m, alg)

Compute response time bounds for each task in the [`TaskSystem`](@ref) `T` under GEDF
scheduling on `m` processors, according to the specified algorithm.
"""
function response_time_gedf(T::TaskSystem{<:PeriodicImplicitTask}, m::Integer, alg::GEDFAlgorithm)
    return tardiness_gedf(T, m, alg) .+ deadline.(T)
end

"""
    tardiness_gedf(T, m, ::GEDFDeviAndersonAlg)

Compute tardiness bounds for each task in the [`TaskSystem`](@ref) `T` under GEDF
scheduling on `m` processors, according to the `GEDFDeviAnderson` algorithm.
"""
function tardiness_gedf(T::TaskSystem{<:PeriodicImplicitTask}, m::Integer, ::GEDFDeviAndersonAlg)
    m > 1 || throw(ArgumentError("m must be at least 2"))
    utilization(T) <= m || throw(ArgumentError("T must be feasible on m processors"))

    # Corollary 1 from Devi and Anderson
    Λ = ceil(typeof(m), utilization(T)) - 1
    ϵ = sort(T, by=cost, rev=true)
    μ = sort(T, by=utilization, rev=true)
    if Λ >= 2
        x = (sum(cost, ϵ[1:Λ]) - cost(ϵ[end])) / (m - sum(utilization, μ[1:Λ-1]))
    elseif Λ == 1
        x = (sum(cost, ϵ[1:Λ]) - cost(ϵ[end])) / m
    else
        @info Λ
        # If Λ == 0, utilization(T) <= 1, so EDF is optimal
        return 0.0
    end
    return x .+ cost.(T)
end
