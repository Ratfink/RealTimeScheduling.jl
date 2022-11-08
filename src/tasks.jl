"""
Abstract parent type of all real-time task types
"""
abstract type AbstractRealTimeTask{S <: Real} end

Base.length(_::AbstractRealTimeTask) = 1
Base.iterate(τ::AbstractRealTimeTask) = (τ, nothing)
Base.iterate(_::AbstractRealTimeTask, _) = nothing

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
# True by definition, so don't even bother checking
implicit_deadline(τ::PeriodicImplicitTask) = true
constrained_deadline(τ::PeriodicImplicitTask) = true

# Conversion rules for Periodic[Implicit]Task
Base.convert(::Type{PeriodicTask{T}}, τ::PeriodicTask{S}) where {T<:Real, S<:Real} = PeriodicTask{T}(τ.T, τ.D, τ.C)
Base.convert(::Type{PeriodicImplicitTask{T}}, τ::PeriodicImplicitTask{S}) where {T<:Real, S<:Real} = PeriodicImplicitTask{T}(τ.T, τ.C)
Base.convert(::Type{PeriodicTask{T}}, τ::PeriodicImplicitTask{S}) where {T<:Real, S<:Real} = PeriodicTask{T}(τ.T, τ.T, τ.C)
Base.convert(::Type{PeriodicTask}, τ::PeriodicImplicitTask{T}) where {T<:Real} = PeriodicTask{T}(τ.T, τ.T, τ.C)

# Promotion rules for Periodic[Implicit]Task
Base.promote_rule(::Type{PeriodicTask{T}}, ::Type{PeriodicTask{S}}) where {T<:Real, S<:Real} = PeriodicTask{promote_type(T, S)}
Base.promote_rule(::Type{PeriodicTask{T}}, ::Type{PeriodicImplicitTask{S}}) where {T<:Real, S<:Real} = PeriodicTask{promote_type(T, S)}
Base.promote_rule(::Type{PeriodicImplicitTask{T}}, ::Type{PeriodicImplicitTask{S}}) where {T<:Real, S<:Real} = PeriodicImplicitTask{promote_type(T, S)}

"""
    PeriodicWeaklyHardTask{S, R}(period::S, deadline::S, cost::S, constraint::R)

Concrete type for periodic tasks with a weakly hard constraint.
"""
struct PeriodicWeaklyHardTask{S,R} <: AbstractRealTimeTask{S} where {R<:WeaklyHardConstraint}
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
    """
    The weakly hard constraint the task must satisfy for correct execution
    """
    constraint::R
end

period(τ::PeriodicWeaklyHardTask) = τ.T
deadline(τ::PeriodicWeaklyHardTask) = τ.D
cost(τ::PeriodicWeaklyHardTask) = τ.C
constraint(τ::PeriodicWeaklyHardTask) = τ.constraint

"""
    min_utilization(τ::PeriodicWeaklyHardTask)

Compute the minimum utilization of weakly hard real-time task `τ`, representing the
utilization of the task if as few jobs as possible are executed.

See also [`utilization`](@ref), [`density`](@ref), and [`min_density`](@ref).
"""
min_utilization(_::PeriodicWeaklyHardTask) = throw(MethodError(min_utilization, "Not implemented for this constraint"))
min_utilization(τ::PeriodicWeaklyHardTask{<:Real,<:MeetAny}) = utilization(τ) * constraint(τ).meet / constraint(τ).window
min_utilization(τ::PeriodicWeaklyHardTask{<:Union{Integer, Rational},<:MeetAny}) = utilization(τ) * constraint(τ).meet // constraint(τ).window
min_utilization(τ::PeriodicWeaklyHardTask{<:Real,<:MeetRow}) = utilization(τ) * min((2*constraint(τ).meet - 1) / constraint(τ).window, 1)
min_utilization(τ::PeriodicWeaklyHardTask{<:Union{Integer, Rational},<:MeetRow}) = utilization(τ) * min((2*constraint(τ).meet - 1) // constraint(τ).window, 1)
min_utilization(τ::PeriodicWeaklyHardTask{<:Real,<:MissRow}) = utilization(τ) / (constraint(τ).miss + 1)
min_utilization(τ::PeriodicWeaklyHardTask{<:Union{Integer, Rational},<:MissRow}) = utilization(τ) // (constraint(τ).miss + 1)
min_utilization(τ::PeriodicWeaklyHardTask{<:Real,<:HardRealTime}) = utilization(τ)
min_utilization(τ::PeriodicWeaklyHardTask{<:Real,<:BestEffort}) = 0

"""
    min_density(τ::PeriodicWeaklyHardTask)

Compute the minimum density of weakly hard real-time task `τ`, representing the
density of the task if as few jobs as possible are executed.

See also [`utilization`](@ref), [`density`](@ref), and [`min_utilization`](@ref).
"""
min_density(_::PeriodicWeaklyHardTask) = throw(MethodError(min_density, "Not implemented for this constraint"))
min_density(τ::PeriodicWeaklyHardTask{<:Real,<:MeetAny}) = density(τ) * constraint(τ).meet / constraint(τ).window
min_density(τ::PeriodicWeaklyHardTask{<:Union{Integer, Rational},<:MeetAny}) = density(τ) * constraint(τ).meet // constraint(τ).window
min_density(τ::PeriodicWeaklyHardTask{<:Real,<:MeetRow}) = density(τ) * min((2*constraint(τ).meet - 1) / constraint(τ).window, 1)
min_density(τ::PeriodicWeaklyHardTask{<:Union{Integer, Rational},<:MeetRow}) = density(τ) * min((2*constraint(τ).meet - 1) // constraint(τ).window, 1)
min_density(τ::PeriodicWeaklyHardTask{<:Real,<:MissRow}) = density(τ) / (constraint(τ).miss + 1)
min_density(τ::PeriodicWeaklyHardTask{<:Union{Integer, Rational},<:MissRow}) = density(τ) // (constraint(τ).miss + 1)
min_density(τ::PeriodicWeaklyHardTask{<:Real,<:HardRealTime}) = density(τ)
min_density(τ::PeriodicWeaklyHardTask{<:Real,<:BestEffort}) = 0



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

See also [`density`](@ref).
"""
utilization(τ::AbstractRealTimeTask) = cost(τ) / period(τ)
utilization(τ::AbstractRealTimeTask{<:Union{Integer, Rational}}) = cost(τ) // period(τ)

"""
    density(τ::AbstractRealTimeTask)

Compute the density of real-time task `τ`, cost/min(period, deadline).

See also [`utilization`](@ref).
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

```math
\\max\\left(0, \\left\\lfloor \\frac{t - \\mathrm{deadline}(τ)}{\\mathrm{period}(τ)} + 1 \\right\\rfloor \\mathrm{cost}(τ) \\right)
```
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

```math
\\left\\lceil \\frac{t}{\\mathrm{period}(τ)}\\right\\rceil \\mathrm{cost}(τ)
```
"""
function request_bound(τ::AbstractRealTimeTask, t::Real)
    if t < 0
        return 0
    end
    return ceil(Integer, t / period(τ)) * cost(τ)
end
