using DataStructures
using IntervalSets
using RecipesBase


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
    ExecInterval{typeof(l)}(l, r, processor(i))
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

"""
    RealTimeTaskSchedule(T::Type, tasks::AbstractRealTimeTaskSystem)

Create a [`RealTimeTaskSchedule{T}`](@ref) with an empty job list for each task.
"""
function RealTimeTaskSchedule(T::Type, tasks::AbstractRealTimeTaskSystem)
    jobs = Vector{Vector{T}}(undef, length(tasks))
    for v in eachindex(jobs)
        jobs[v] = T[]
    end
    RealTimeTaskSchedule{T}(tasks, jobs)
end

function schedule_gedf(release!, T::AbstractRealTimeTaskSystem, m::Int, endtime::Real)
    timetype = typeof(endtime)
    jobtype = JobOfTask{timetype, eltype(T)}
    # Create the schedule
    sched = RealTimeTaskSchedule(jobtype, T)
    # Scheduler's ready queue
    readyq = PriorityQueue{jobtype, timetype}()

    time = timetype(0)
    proc_jobs = Vector{Union{Nothing,jobtype}}(nothing, m)
    while time < endtime
        nexttime = endtime
        # Release new jobs if needed
        for (i, τ) in enumerate(T)
            jobs = sched.jobs[i]
            # If there is a non-empty current job, don't release a new one
            next_rel = isempty(jobs) ? 0 : period(τ) + release(jobs[end])
            if time < next_rel
                nexttime = min(nexttime, next_rel)
            end
            if !isempty(jobs) && (time < next_rel
                                  || sum(width.(exec(jobs[end]))) < cost(jobs[end]))
                continue
            end
            # TODO make a function to create a job of a task, so this can be properly generic
            j = jobtype(τ, next_rel, next_rel+deadline(τ), cost(τ), next_rel+deadline(τ), ExecInterval{timetype}[])
            release!(j)
            push!(jobs, j)
            enqueue!(readyq, j, priority(j))
        end
        # Clear out any completed jobs
        for (proc, j) in enumerate(proc_jobs)
            # Clear out any completed jobs
            if j !== nothing && sum(width.(exec(j))) >= cost(j)
                proc_jobs[proc] = nothing
                j = nothing
            end
        end
        # Pick jobs to run and find next interesting time instant
        sortby(key) = key[2] === nothing ? typemax(timetype) : priority(key[2])
        for (proc, j) in sort(collect(enumerate(proc_jobs)), by=sortby, rev=true)
            # Pick new jobs for idle processors
            if !isempty(readyq) && j === nothing
                proc_jobs[proc] = dequeue!(readyq)
                j = proc_jobs[proc]
            # Replace lower priority jobs with ones from the queue
            elseif !isempty(readyq) && priority(first(peek(readyq))) < priority(j)
                enqueue!(readyq, j, priority(j))
                proc_jobs[proc] = dequeue!(readyq)
                j = proc_jobs[proc]
            end
            # Find the next interesting time instant
            if j !== nothing
                nexttime = min(nexttime, time+cost(j)-sum(width.(exec(j))))
            end
        end
        # Schedule pending jobs
        for (proc, j) in enumerate(proc_jobs)
            if j === nothing
                continue
            end
            interval = ExecInterval{timetype}(time, nexttime, proc)
            try
                exec(j)[end] = union(exec(j)[end], interval)
            catch
                push!(exec(j), interval)
            end
        end
        # Advance to next interesting time instant
        time = nexttime
    end

    sched
end

schedule_gedf(T::AbstractRealTimeTaskSystem, m::Int, time::Real) = schedule_gedf(identity, T, m, time)

@recipe function scheduleplot(sched::RealTimeTaskSchedule)
    endtime = maximum(rightendpoint.(Iterators.flatten(exec.(Iterators.flatten(sched.jobs)))))
    layout --> (length(sched.tasks), 1)
    xlims --> (0, endtime)
    ylims --> (0, 2)
    yticks --> false
    xgrid --> false
    # First draw the execution intervals
    for (i, τ) in enumerate(sched.jobs)
        for j in τ
            for ei in exec(j)
                l, r = endpoints(ei)
                @series begin
                    subplot := i
                    label --> ""
                    seriestype := :shape
                    fillcolor --> processor(ei)
                    [l, r, r, l], [0, 0, 1, 1]
                end
            end
        end
    end
    # Then the release, deadline, and completion arrows
    for (i, τ) in enumerate(sched.jobs)
        for j in τ
            rel = release(j)
            dead = deadline(j)
            total_exec = sum(width.(exec(j)))
            comp = total_exec == cost(j) ? maximum(rightendpoint.(exec(j))) : -1
            # Release
            @series begin
                subplot := i
                label --> ""
                seriestype := :path
                linecolor --> :black
                arrow := true
                [rel, rel], [0, 2]
            end
            # Deadline
            @series begin
                subplot := i
                label --> ""
                seriestype := :path
                linecolor --> :black
                arrow := true
                [dead, dead], [2, 0]
            end
            # Completion
            @series begin
                subplot := i
                label --> ""
                seriestype := :path
                linecolor --> :black
                markershape := [:none, :hline]
                markeralpha --> [0, 1]
                markerstrokewidth --> 2*get(plotattributes, :linewidth, 1)
                markerstrokecolor --> :black
                markercolor --> :black
                [comp, comp], [0, 2]
            end
        end
    end
    # Per-subplot settings
    for (i, τ) in enumerate(sched.tasks)
        @series begin
            subplot := i
            if i == length(sched.tasks)
                xguide --> "Time"
            end
            yguide --> "Task $i"
            label --> ""
            [0], [0]
        end
    end
end
