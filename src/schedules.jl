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
    exec(j::AbstractJob)

Return the execution intervals of job `j`.

See also [`exectime`](@ref).
"""
exec(::AbstractJob) = error("Implement exec")

"""
    exectime(j::AbstractJob)

Return the total time occupied by all execution intervals of job `j`.

See also [`exec`](@ref).
"""
exectime(j::AbstractJob) = sum(width.(exec(j)))

"""
    completed(j::AbstractJob)

Return whether the job `j` has completed, i.e., whether `exectime(j) >= cost(j)`.
"""
completed(j::AbstractJob) = exectime(j) >= cost(j)


"""
    completiontime(j::AbstractJob)

Return the absolute completion time of job `j`, if it has completed.  Throw an
`ArgumentError` otherwise.
"""
function completiontime(j::AbstractJob)
    if completed(j)
        maximum(supremum.(exec(j)))
    else
        throw(ArgumentError("j has not completed"))
    end
end

"""
    responsetime(j::AbstractJob)

Return the response time of job `j`, if it has completed.  Throw an `ArgumentError`
otherwise.
"""
responsetime(j::AbstractJob) = completiontime(j) - release(j)

"""
    Job{S}(release::S, deadline::S, cost::S, priority::S, exec::Vector{ExecInterval{S}}

A real-time job with the given parameters, executing over the intervals in `exec`.
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
    JobOfTask{S, T}(task::T, release::S, deadline::S, cost::S, priority::S, exec::Vector{ExecInterval{S}}

A real-time job of the given `task` with the given parameters, executing over the intervals
in `exec`.
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
    RealTimeTaskSchedule{T}(tasks::AbstractRealTimeTaskSystem, jobs::Vector{Vector{T}})

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

"""
    schedule_global(release!, T, m, endtime; kill=false)

Simulate a preemptive global schedule of task system `T` on `m` processors to the specified
`endtime`.  When releasing a job, the function `release!(job)` is called, allowing
arbitrary modifications to be made, enabling a wide variety of global schedulers to be
implemented.  Three examples are provided: [`schedule_gfp`](@ref), [`schedule_gedf`](@ref),
and [`schedule_gfl`](@ref).

The `job` provided to `release!(job)` defaults to being released as early as possible (i.e.
at time 0 or one period after the task's last job), and has the relative deadline and cost
specified by the task.  The priority defaults to the task's index in `T`, with lower
priority values being treated as higher priority by the scheduler.

If `kill` is `true`, jobs are killed at their deadline if they have not yet completed.
"""
function schedule_global(release!, T::AbstractRealTimeTaskSystem, m::Int, endtime::Real; kill::Bool=false)
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
            # Get the next release time of this task
            next_rel = isempty(jobs) ? 0 : period(τ) + release(jobs[end])
            # Make a scheduling decision at the next release time
            if time < next_rel
                nexttime = min(nexttime, next_rel)
            end
            # If there is a non-empty current job, don't release a new one
            if !isempty(jobs) && (time < next_rel || (!kill && !completed(jobs[end]))
                                  || (kill && !completed(jobs[end])
                                      && time <= deadline(jobs[end])))
                continue
            end
            # Release the new job
            j = jobtype(τ, next_rel, next_rel+deadline(τ), cost(τ), i, ExecInterval{timetype}[])
            release!(j)
            push!(jobs, j)
            enqueue!(readyq, j, priority(j))
        end
        # Clear out whatever jobs we have to
        for (proc, j) in enumerate(proc_jobs)
            # Clear out any completed jobs
            if j !== nothing && completed(j)
                proc_jobs[proc] = nothing
            end
            # If asked to, remove jobs that have missed their deadline
            if kill && j !== nothing && time >= deadline(j)
                proc_jobs[proc] = nothing
            end
        end
        # If asked to, remove jobs from the ready queue if they missed their deadline
        if kill
            for (j, _) in readyq
                if time >= deadline(j)
                    delete!(readyq, j)
                end
            end
        end
        # Pick jobs to run and find next interesting time instant
        sortby(key) = key[2] === nothing ? typemax(timetype) : priority(key[2])
        for (proc, j) in sort(collect(enumerate(proc_jobs)), by=sortby, rev=true)
            # Pick new jobs for processors running nothing or lower priority jobs
            if !isempty(readyq) && (j === nothing || priority(first(peek(readyq))) < priority(j))
                if j !== nothing
                    enqueue!(readyq, j, priority(j))
                end
                proc_jobs[proc] = dequeue!(readyq)
                j = proc_jobs[proc]
            end
            # Find the next interesting time instant
            if j !== nothing
                nexttime = min(nexttime, time+cost(j)-exectime(j))
                if deadline(j) > time
                    nexttime = min(nexttime, deadline(j))
                end
            end
        end
        # Schedule pending jobs
        for (proc, j) in enumerate(proc_jobs)
            if j === nothing
                continue
            end
            interval = ExecInterval{timetype}(timetype(time), timetype(nexttime), proc)
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

"""
    schedule_gfp(T, m, time; kill=false)

Simulate a preemptive global fixed priority (GFP) schedule of task system `T` on `m`
processors for the specified `time`.  Tasks are prioritized by their index in `T`, lowest
index first.

If `kill` is `true`, jobs are killed at their deadline if they have not yet completed.

See also [`schedule_global`](@ref) for more general global scheduling.
"""
schedule_gfp(T::AbstractRealTimeTaskSystem, m::Int, time::Real; kill::Bool=false) = schedule_global(identity, T, m, time; kill=kill)

"""
    schedule_gedf(T, m, time; kill=false)

Simulate a preemptive global earliest-deadline-first (GEDF) schedule of task system `T` on
`m` processors for the specified `time`.

If `kill` is `true`, jobs are killed at their deadline if they have not yet completed.

See also [`schedule_global`](@ref) for more general global scheduling.
"""
schedule_gedf(T::AbstractRealTimeTaskSystem, m::Int, time::Real; kill::Bool=false) = schedule_global(T, m, time, kill=kill) do j
    j.priority = deadline(j)
end

"""
    schedule_gfl(T, m, time)

Simulate a preemptive global fair lateness (GFL) schedule of task system `T` on `m`
processors for the specified `time`.  This provides the lowest tardiness bounds of any
GEDF-like scheduler under compliant vector analysis; for more information, see Erickson,
"Managing Tardiness Bounds and Overload in Soft Real-Time Systems."
DOI: [10.17615/fvp3-q039](https://doi.org/10.17615/fvp3-q039).

See also [`schedule_global`](@ref) for more general global scheduling.
"""
schedule_gfl(T::AbstractRealTimeTaskSystem, m::Int, time::Real) = schedule_global(T, m, time) do j
    j.priority = deadline(j) - (m - 1) / m * cost(j)
end

@recipe function scheduleplot(sched::RealTimeTaskSchedule)
    endtime = maximum(supremum.(Iterators.flatten(exec.(Iterators.flatten(sched.jobs)))))
    layout --> (length(sched.tasks), 1)
    xlims --> (0, endtime)
    ylims --> (0, 2)
    ytickfontcolor --> "#00000000" # Workaround for guides getting cut off
    yticks --> [0]
    xgrid --> false
    ygrid --> false
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
            comp = completed(j) ? completiontime(j) : -1
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
                xticks --> true
            else
                xticks --> false
            end
            yguide --> "Task $i"
            yguidefonthalign --> :left
            label --> ""
            [0], [0]
        end
    end
end
