"""
Abstract parent type of all real-time task types
"""
abstract type AbstractRealTimeTask{S <: Real} end

"""
    PeriodicTask{S}(period::S, deadline::S, cost::S)

Concrete type for periodic real-time tasks.
"""
struct PeriodicTask{S} <: AbstractRealTimeTask{S}
    """
    The period, or interrelease time
    """
    T::S
    """
    The relative deadline
    """
    D::S
    """
    The cost, or worst-case execution time (WCET)
    """
    C::S
end

"""
    period(τ)

Return the period of the real-time task `τ`.
"""
period(τ::PeriodicTask) = τ.T
"""
    deadline(τ)

Return the deadline of the real-time task `τ`.
"""
deadline(τ::PeriodicTask) = τ.D
"""
    cost(τ)

Return the cost, or worst-case execution time, of the real-time task `τ`.
"""
cost(τ::PeriodicTask) = τ.C


"""
    PeriodicImplicitTask{S}(period::S, cost::S)

Concrete type for periodic real-time tasks with implicit deadline.
"""
struct PeriodicImplicitTask{S} <: AbstractRealTimeTask{S}
    """
    The period, or interrelease time
    """
    T::S
    """
    The cost, or worst-case execution time (WCET)
    """
    C::S
end

period(τ::PeriodicImplicitTask) = τ.T
deadline(τ::PeriodicImplicitTask) = τ.T
cost(τ::PeriodicImplicitTask) = τ.C


"""
    implicit_deadline(τ::AbstractRealTimeTask)

Test whether the real-time task `τ` has relative deadline equal to period.
"""
implicit_deadline(τ::AbstractRealTimeTask) = deadline(τ) == period(τ)

"""
    constrained_deadline(τ::AbstractRealTimeTask)

Test whether the real-time task `τ` has relative deadline at most period.
"""
constrained_deadline(τ::AbstractRealTimeTask) = deadline(τ) <= period(τ)

"""
    utilization(τ::AbstractRealTimeTask)

Compute the utilization of real-time task `τ`, cost/period.
"""
utilization(τ::AbstractRealTimeTask) = cost(τ)/ period(τ)
utilization(τ::AbstractRealTimeTask{<:Union{Integer, Rational}}) = cost(τ) // period(τ)

"""
    density(τ::AbstractRealTimeTask)

Compute the density of real-time task `τ`, cost/min(period, deadline).
"""
density(τ::AbstractRealTimeTask) = cost(τ) / minimum([period(τ), deadline(τ)])
density(τ::AbstractRealTimeTask{<:Union{Integer, Rational}}) = cost(τ) // minimum([period(τ), deadline(τ)])

"""
    feasible(τ::AbstractRealTimeTask)

Test whether the real-time task `τ` is feasible, i.e. its density is at most 1.
"""
feasible(τ::AbstractRealTimeTask) = cost(τ) <= minimum([period(τ), deadline(τ)])

"""
    demand_bound(τ::AbstractRealTimeTask, t)

Compute Baruah's demand bound function (DBF) for the task `τ`.
"""
function demand_bound(τ::AbstractRealTimeTask, t::Real)
    if t <= 0
        return 0
    end
    maximum([0, (floor(Integer, (t - deadline(τ)) / period(τ)) + 1) * cost(τ)])
end

"""
    request_bound(τ::AbstractRealTimeTask, t)

Compute the request bound function (RBF) for the task `τ`.
"""
function request_bound(τ::AbstractRealTimeTask, t::Real)
    if t < 0
        return 0
    end
    return (floor(Integer, t / period(τ)) + 1) * cost(τ)
end
