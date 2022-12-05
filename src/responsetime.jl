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

Indicate that a response time bound should be computed according to Erickson, Guan, and
Baruah, "Tardiness Bounds for Global EDF with Deadlines Different from Periods."
DOI: https://doi.org/10.1007/978-3-642-17653-1_22
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
scheduling on `m` processors, according to the `GEDFDeviAnderson` algorithm.
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

_S(τ::AbstractRealTimeTask) = cost(τ) * max(0, 1 − deadline(τ) / period(τ))
_S(T::AbstractRealTimeTaskSystem) = sum(_S, T)

"""
    tardiness_gedf(T, m, ::GEDFCompliantVectorAlg)

Compute tardiness bounds for each task in the [`TaskSystem`](@ref) `T` under GEDF
scheduling on `m` processors, according to the `GEDFCompliantVector` algorithm.
"""
function tardiness_gedf(T::TaskSystem{<:AbstractRealTimeTask}, m::Integer, ::GEDFCompliantVectorAlg)
    m > 1 || throw(ArgumentError("m must be at least 2"))
    utilization(T) <= m || throw(ArgumentError("T must be feasible on m processors"))
    utilization(T) > 1 || return zeros(length(T))

    # Algorithm 1 from Erickson, Guan, and Baruah
    m0 = ceil(Int, utilization(T))
    _z(i, j) = (cost(i) + (cost(j)*utilization(j)) / m + (-cost(i)*utilization(i)) / m - cost(j)) / (utilization(j) - utilization(i))
    points = Tuple{Float64, AbstractRealTimeTask, AbstractRealTimeTask}[]
    for i in eachindex(T)
        for j in 1:i-1
            if utilization(T[i]) != utilization(T[j])
                push!(points, (_z(T[i], T[j]), T[i], T[j]))
            else
                push!(points, (0, T[i], T[j]))
            end
        end
    end
    sort!(points, by=p -> p[1])

    z0 = 0
    pind = 1
    if pind <= length(points)
        z1, i, j = points[pind]
    else
        z1 = Inf
    end

    _sumterm(τ) = utilization(τ) * (-cost(τ) / m) + cost(τ)
    Θ = sort(T, by=_sumterm, rev=true)[1:m0]
    @info typeof(Θ)
    @info "points" points
    zstar = 0
    while true
        @info "status" zstar z0 z1
        zstar = ((_S(T) - sum(cost, Θ) + sum(τ -> (utilization(τ) * cost(τ) / m), Θ))
                 / (utilization(Θ) - m))
        if z0 <= zstar <= z1 || z0 == z1 == Inf
            break
        elseif i ∈ Θ && j ∉ Θ && utilization(j) > utilization(i)
            Θ[findfirst(task -> task === i, Θ)] = j
        end
        z0 = z1
        if pind <= length(points)
            z1, i, j = points[pind]
        else
            z1 = Inf
        end
        pind += 1
    end

    return zstar .- cost.(T) ./ m .+ cost.(T)
end
