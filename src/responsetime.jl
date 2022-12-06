using JuMP
using Clp


abstract type GEDFAlgorithm end

struct GEDFDeviAndersonAlg <: GEDFAlgorithm end
struct GEDFCompliantVectorAlg <: GEDFAlgorithm end

"""
    GEDFDeviAnderson

Indicate that a response time bound should be computed according to Devi and Anderson,
"Tardiness Bounds under Global EDF Scheduling on a Multiprocessor."
DOI: https://doi.org/10.1007/s11241-007-9042-1
"""
const GEDFDeviAnderson = GEDFDeviAndersonAlg()

"""
    GEDFCompliantVector

Indicate that a response time bound should be computed according to Erickson, "Managing
Tardiness Bounds and Overload in Soft Real-Time Systems." ISBN: 978-1-321-14155-9
"""
const GEDFCompliantVector = GEDFCompliantVectorAlg()

"""
    response_time_gedf(T, m, alg)

Compute response time bounds for each task in the [`TaskSystem`](@ref) `T` under GEDF
scheduling on `m` processors, according to the specified algorithm.
"""
function response_time_gedf(T::TaskSystem{<:AbstractRealTimeTask}, m::Integer, alg::GEDFAlgorithm)
    return tardiness_gedf(T, m, alg) .+ deadline.(T)
end

"""
    tardiness_gedf(T, m, ::GEDFDeviAndersonAlg)

Compute tardiness bounds for each task in the [`TaskSystem`](@ref) `T` under GEDF
scheduling on `m` processors, according to the [`GEDFDeviAnderson`](@ref) algorithm.
"""
function tardiness_gedf(T::TaskSystem{<:PeriodicImplicitTask}, m::Integer, ::GEDFDeviAndersonAlg)
    m > 1 || throw(ArgumentError("m must be at least 2"))
    utilization(T) <= m || throw(ArgumentError("T must be feasible on m processors"))

    # Corollary 1 from Devi and Anderson
    Λ = ceil(typeof(m), utilization(T)) - 1
    ϵ = sort(T, by=cost, rev=true)
    μ = sort(T, by=utilization, rev=true)
    if Λ == 0
        # If Λ == 0, utilization(T) <= 1, so EDF is optimal
        return 0.0
    elseif Λ == 1
        x = (sum(cost, ϵ[1:Λ]) - cost(ϵ[end])) / m
    else
        x = (sum(cost, ϵ[1:Λ]) - cost(ϵ[end])) / (m - sum(utilization, μ[1:Λ-1]))
    end
    return x .+ cost.(T)
end

"""
    tardiness_gedf(T, m, ::GEDFCompliantVectorAlg)

Compute tardiness bounds for each task in the [`TaskSystem`](@ref) `T` under GEDF
scheduling on `m` processors, according to the [`GEDFCompliantVector`](@ref) algorithm.
"""
function tardiness_gedf(T::TaskSystem{<:AbstractRealTimeTask}, m::Integer, ::GEDFCompliantVectorAlg)
    m > 1 || throw(ArgumentError("m must be at least 2"))
    utilization(T) <= m || throw(ArgumentError("T must be feasible on m processors"))
    utilization(T) > 1 || return zeros(length(T))

    # Linear program from chapter 3 of Jeremy Erickson's dissertation
    U⁺ = ceil(Int, utilization(T))

    model = Model(Clp.Optimizer)
    set_optimizer_attribute(model, "LogLevel", 0)
    @variable(model, x[axes(T,1)])
    @variable(model, S[axes(T,1)] >= 0)
    @variable(model, S_sum)
    @variable(model, G)
    @variable(model, s)
    @variable(model, b)
    @variable(model, z[axes(T,1)] >= 0)
    # Constraint set 3.1
    @constraint(model, x .== (s .- cost.(T)) ./ m)
    # Constraint set 3.2
    @constraint(model, S .>= cost.(T) .* (1 .- deadline.(T) ./ period.(T)))
    # Constraint set 3.3
    @constraint(model, G == b * (U⁺ - 1) + sum(z))
    @constraint(model, z .>= x .* utilization.(T) .+ cost.(T) .- S .- b)
    # Constraint set 3.4
    @constraint(model, S_sum == sum(S))
    # Constraint set 3.5
    @constraint(model, s >= G + S_sum)
    # Objective
    @objective(model, Min, s)

    # Proven to always have a solution
    optimize!(model)

    return value.(x) + cost.(T)
end
