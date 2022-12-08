using DataStructures
using IntervalSets


"""
    ExecInterval{S}(start::S, stop::S, proc::Int)

Interval type for job execution, with a specified processor index.  Always assumed to be
half open, i.e., `[start, stop)`.
"""
struct ExecInterval{S} <: AbstractInterval{S}
    start::S
    stop::S
    proc::Int
    function ExecInterval{S}(start::S, stop::S, proc::Int) where {S<:Real}
        @boundscheck start < stop || throw(DomainError("start must be less than stop"))
        @boundscheck proc > 0 || throw(DomainError("proc must be positive"))
        new(start, stop, proc)
    end
end

IntervalSets.endpoints(i::ExecInterval) = (i.start, i.stop)
IntervalSets.closedendpoints(::ExecInterval) = (true, false)
processor(i::ExecInterval) = i.proc

Base.in(x::Real, i::ExecInterval) = leftendpoint(i) <= x < rightendpoint(i)

function Base.union(i::ExecInterval, j::ExecInterval)
    processor(i) == processor(j) ||
        throw(ArgumentError("Cannot construct union of execution on different processors"))
    any(∈(i), endpoints(j)) || any(∈(j), endpoints(i)) ||
        throw(ArgumentError("Cannot construct union of disjoint sets"))
    l = min(leftendpoint(i), leftendpoint(j))
    r = max(rightendpoint(i), rightendpoint(j))
    ExecInterval(l, r, processor(i))
end


"""
    AbstractJob

Abstract supertype for all real-time jobs.
"""
abstract type AbstractJob end

"""
    release(j::AbstractJob)

Return the release time of job `j`.
"""
release(::AbstractJob) = error("Implement release")

"""
    deadline(j::AbstractJob)

Return the absolute deadline of job `j`.
"""
deadline(::AbstractJob) = error("Implement deadline")

"""
    cost(j::AbstractJob)

Return the execution cost of job `j`.
"""
cost(::AbstractJob) = error("Implement cost")

"""
    priority(j::AbstractJob)

Return the priority of job `j`.
"""
priority(::AbstractJob) = error("Implement priority")

"""
Real-time job type.
"""
mutable struct Job{S} <: AbstractJob
    release::S
    deadline::S
    cost::S
    priority::S
    exec::Vector{ExecInterval{S}}
end

release(j::Job) = j.release
deadline(j::Job) = j.deadline
cost(j::Job) = j.cost
priority(j::Job) = j.priority
exec(j::Job) = j.exec

"""
    AbstractJobOfTask{T}

Abstract supertype for all real-time jobs of tasks.
"""
abstract type AbstractJobOfTask{T <: AbstractRealTimeTask} <: AbstractJob end

"""
    task(j::AbstractJobOfTask)

Return the task associated with job `j`.
"""
task(::AbstractJobOfTask) = error("Implement task")

"""
Job of a real-time task.
"""
mutable struct JobOfTask{S <: Real, T} <: AbstractJobOfTask{T}
    task::T
    release::S
    deadline::S
    cost::S
    priority::S
    exec::Vector{ExecInterval{S}}
end

task(j::JobOfTask) = j.task
release(j::JobOfTask) = j.release
deadline(j::JobOfTask) = j.deadline
cost(j::JobOfTask) = j.cost
priority(j::JobOfTask) = j.priority
exec(j::JobOfTask) = j.exec


"""
    AbstractSchedule{T}

Abstract supertype for all real-time schedules.
"""
abstract type AbstractSchedule{T <: AbstractJob} end

"""
    AbstractTaskSchedule{T}

Abstract supertype for all real-time schedules of task systems.
"""
abstract type AbstractTaskSchedule{T <: AbstractJobOfTask} <: AbstractSchedule{T} end

"""
Schedule of a real-time task system.
"""
mutable struct RealTimeTaskSchedule{T} <: AbstractTaskSchedule{T}
    tasks::AbstractRealTimeTaskSystem
    jobs::Vector{Vector{T}}
end

function schedule_gedf(release!, T::AbstractRealTimeTaskSystem, m::Int, time::Real)
    # Create the schedule
    sched = RealTimeTaskSchedule(T, Vector{Vector{JobOfTask{typeof(time), eltype(T)}}}(undef, length(T)))
    # Initialize the job vectors as empty
    for v in eachindex(sched.jobs)
        sched.jobs[v] = JobOfTask{typeof(time), eltype(T)}[]
    end
    # Scheduler's priority queue
    pq = PriorityQueue{eltype(T), typeof(time)}()
    sched
end

schedule_gedf(T::AbstractRealTimeTaskSystem, m::Int, time::Real) = schedule_gedf(identity, T, m, time)
