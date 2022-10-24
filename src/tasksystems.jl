"""
Abstract parent type of all real-time task system types
"""
abstract type AbstractRealTimeTaskSystem{T <: AbstractRealTimeTask} <: AbstractVector{T} end

"""
    TaskSystem{T} <: AbstractRealTimeTaskSystem

A concrete real-time task system, holding a [`Vector`](@ref) of tasks of type `T`.
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
utilization(T::AbstractRealTimeTaskSystem) = sum(utilization, T)

"""
    density(T::AbstractRealTimeTaskSystem)

Return the sum density of all tasks in `T`.
"""
density(T::AbstractRealTimeTaskSystem) = sum(density, T)

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
demand_bound(T::AbstractRealTimeTaskSystem, t::Real) = sum(τ -> demand_bound(τ, t), T)

"""
    request_bound(T::AbstractRealTimeTaskSystem, t)

Compute the request bound function (RBF) for task system `T`.
"""
request_bound(T::AbstractRealTimeTaskSystem, t::Real) = sum(τ -> request_bound(τ, t), T)
