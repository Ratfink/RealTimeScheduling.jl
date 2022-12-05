using Distributions


"""
Abstract parent type of all real-time task system types
"""
abstract type AbstractRealTimeTaskSystem{T <: AbstractRealTimeTask} <: AbstractVector{T} end

"""
    TaskSystem{T} <: AbstractRealTimeTaskSystem

A concrete real-time task system, holding a `Vector` of tasks of type `T`.
"""
mutable struct TaskSystem{T} <: AbstractRealTimeTaskSystem{T}
    """
    The tasks contained within the TaskSystem
    """
    tasks::Vector{T}
end

"""
    TaskSystem{T}(undef, n)

Construct an uninitialized `TaskSystem{T}` of `n` tasks.
"""
TaskSystem{T}(undef::UndefInitializer, n::Integer) where {T <: AbstractRealTimeTask} = TaskSystem(Vector{T}(undef, n))

"""
    TaskSystem{T}(nothing, n)

Construct a `TaskSystem{T}` of `n` tasks, initialized with `nothing` entries.  Element
type `T` must be able to hold these values, i.e. `Nothing <: T`.
"""
TaskSystem{T}(nothing::Nothing, n::Integer) where {T <: AbstractRealTimeTask} = TaskSystem(Vector{T}(nothing, n))

"""
    TaskSystem{T}(missing, n)

Construct a `TaskSystem{T}` of `n` tasks, initialized with `missing` entries.  Element
type `T` must be able to hold these values, i.e. `Missing <: T`.
"""
TaskSystem{T}(missing::Missing, n::Integer) where {T <: AbstractRealTimeTask} = TaskSystem(Vector{T}(missing, n))

# Collection methods
Base.isempty(T::TaskSystem) = isempty(T.tasks)
Base.empty!(T::TaskSystem) = empty!(T.tasks)
Base.length(T::TaskSystem) = length(T.tasks)
Base.size(T::TaskSystem) = size(T.tasks)
Base.eltype(T::TaskSystem) = eltype(T.tasks)
Base.iterate(T::TaskSystem) = iterate(T.tasks)
Base.iterate(T::TaskSystem, i) = iterate(T.tasks, i)
Base.getindex(T::TaskSystem, i::Integer) = T.tasks[i]
Base.getindex(T::TaskSystem, inds) = TaskSystem(getindex(T.tasks, inds))
Base.setindex!(T::TaskSystem{S}, value::S, i::Integer) where {S <: AbstractRealTimeTask} = setindex!(T.tasks, value, i)
function Base.similar(T::TaskSystem{S}, element_type::Type{U}=eltype(T), dims::Tuple{Vararg{Int64, N}}=size(T)) where {S <: AbstractRealTimeTask, U, N}
    if element_type <: AbstractRealTimeTask && length(dims) == 1
        TaskSystem{element_type}(undef, dims[1])
    else
        Array{element_type}(undef, dims)
    end
end
Base.resize!(T::TaskSystem, i::Integer) = resize!(T.tasks, i)

"""
    implicit_deadline(T::AbstractRealTimeTaskSystem)

Test whether all real-time tasks in `T` are implicit deadline.
"""
implicit_deadline(T::AbstractRealTimeTaskSystem) = all(implicit_deadline, T)

"""
    constrained_deadline(T::AbstractRealTimeTaskSystem)

Test whether all real-time tasks in `T` are constrained deadline.
"""
constrained_deadline(T::AbstractRealTimeTaskSystem) = all(constrained_deadline, T)

"""
    utilization(T::AbstractRealTimeTaskSystem)

Return the sum utilization of all tasks in `T`.
"""
utilization(T::AbstractRealTimeTaskSystem) = sum(utilization, T, init=0)

"""
    density(T::AbstractRealTimeTaskSystem)

Return the sum density of all tasks in `T`.
"""
density(T::AbstractRealTimeTaskSystem) = sum(density, T, init=0)

"""
    min_utilization(T::AbstractRealTimeTaskSystem)

Return the sum min_utilization of all tasks in `T`.
"""
min_utilization(T::AbstractRealTimeTaskSystem) = sum(min_utilization, T, init=0)

"""
    min_density(T::AbstractRealTimeTaskSystem)

Return the sum min_density of all tasks in `T`.
"""
min_density(T::AbstractRealTimeTaskSystem) = sum(min_density, T, init=0)

"""
    feasible(T::AbstractRealTimeTaskSystem)

Test whether the real-time task system `T` is feasible, i.e. its density is at most 1.
"""
feasible(T::AbstractRealTimeTaskSystem) = density(T) <= 1

"""
    rate_monotonic!(T::AbstractRealTimeTaskSystem)

Sort the task system `T` from lowest to highest period.
"""
rate_monotonic!(T::AbstractRealTimeTaskSystem) = sort!(T, by=period)

"""
    deadline_monotonic!(T::AbstractRealTimeTaskSystem)

Sort the task system `T` from lowest to highest period.
"""
deadline_monotonic!(T::AbstractRealTimeTaskSystem) = sort!(T, by=deadline)

"""
    demand_bound(T::AbstractRealTimeTaskSystem, t)

Compute Baruah's demand bound function (DBF) for task system `T`.
"""
demand_bound(T::AbstractRealTimeTaskSystem, t::Real) = sum(τ -> demand_bound(τ, t), T, init=0)

"""
    request_bound(T::AbstractRealTimeTaskSystem, t)

Compute the request bound function (RBF) for task system `T`.
"""
request_bound(T::AbstractRealTimeTaskSystem, t::Real) = sum(τ -> request_bound(τ, t), T, init=0)

"""
    randtasksystem([tasktype=PeriodicImplicitTask{Float64}], U::Real,
                   utilization_dist::Univariate, period_dist::Univariate)

Generate a random [`TaskSystem`](@ref) with utilization at most `U`.  Tasks are drawn one at a time
with utilizations drawn from `utilization_dist`, and periods from `period_dist`.  The task
system is returned once the next task generated would cause its utilization to exceed `U`.
"""
function randtasksystem(_::Type{PeriodicImplicitTask{S}}, U::Real, utilization_dist::UnivariateDistribution, period_dist::UnivariateDistribution) where {S <: Real}
    T = TaskSystem{PeriodicImplicitTask{S}}(undef, 0)

    while utilization(T) < U
        u = rand(utilization_dist)
        t = rand(period_dist)
        c = t*u
        if S <: Integer
            t = round(S, t)
            c = round(S, c)
        end
        append!(T, PeriodicImplicitTask{S}(t, c))
    end

    # Return all but the last task, so the utilization bound isn't exceeded
    return T[begin:end-1]
end

function randtasksystem(U::Real, utilization_dist::UnivariateDistribution, period_dist::UnivariateDistribution)
    randtasksystem(PeriodicImplicitTask{Float64}, U, utilization_dist, period_dist)
end
