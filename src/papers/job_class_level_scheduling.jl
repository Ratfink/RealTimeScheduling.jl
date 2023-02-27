"""
An implementation of the scheduler and schedulability test from the paper "Toward Practical
Weakly Hard Real-Time Systems: A Job-Class-Level Scheduling Approach" by Choi, Kim, and Zhu.
DOI: [10.1109/JIOT.2021.3058215](https://doi.org/10.1109/JIOT.2021.3058215)
"""
module JobClassLevelScheduling

using ...RealTimeScheduling

export schedule_jcl,
       miss_threshold,
       low_index_first,
       low_index_first_hold,
       wcrt_jcl,
       schedulable_jcl


"""
    schedule_jcl(T, time, prio)

Simulate a job-class-level (JCL) schedule of task system `T` on 1 processor for the
specified `time`.  Job-class priorities are given by `prio`.

See also [`schedule_global`](@ref) for more general global scheduling.
"""
function schedule_jcl(T::AbstractRealTimeTaskSystem, time::Real, prio)
    schedule_global(T, 1, time, kill=true, pass_schedule=true) do j, sched
        task_index = Int(priority(j))
        c = constraint(task(j))
        # Determine job-class of job j
        # Note: our job classes are indexed from 1, not 0 as in the paper
        if c == HardRealTime() || length(sched.jobs[task_index]) == 0
            # Only one class for HRT tasks
            q = 1
        else
            w = miss_threshold(c)
            farthest_back = c.meet + w - 2
            first = max(1, length(sched.jobs[task_index]) - farthest_back)
            jobs = sched.jobs[task_index][end:-1:first]
            comp = completed.(jobs)
            # Find the first hit
            firsthit = 0
            for i in 1:w
                if comp[i]
                    firsthit = i
                    break
                end
            end
            if firsthit == 0
                q = 1
            else
                # Count consecutive hits
                q = 1
                for i in firsthit:min(firsthit+c.meet-1, length(comp))
                    if !comp[i]
                        break
                    end
                    q += 1
                end
            end
        end
        j.priority = prio[task_index][q]
    end
end

"""
    miss_threshold(c::MeetAny)

Compute the miss threshold ``w_i`` for the given [`MeetAny`](@ref) constraint.
"""
miss_threshold(c::MeetAny) = Int(max(floor(c.window / c.meet) - 1, 1))

"""
    miss_threshold(τ::PeriodicWeaklyHardTask{<:Real, MeetAny})

Compute the miss threshold ``w_i`` for the given weakly hard task.
"""
miss_threshold(τ::PeriodicWeaklyHardTask{<:Real, <:MeetAny}) = miss_threshold(constraint(τ))

"""
    low_index_first(T::AbstractRealTimeTaskSystem)

Compute priorities for each job-class of each task in T according to the low-index
job-class first with miss thresholds (LIF-w) heuristic.
"""
function low_index_first(T::AbstractRealTimeTaskSystem)
    N = length(T)
    dm_order = sort(axes(T, 1), by=i->deadline(T[i]))
    # l[i]: number of job-classes for T[i]
    l = zeros(Int, N)
    for i in dm_order
        l[i] = constraint(T[i]).meet + 1
    end
    timetype = typeof(deadline(T[1]))
    prio = 1
    prios = Vector{Vector{timetype}}(undef, N)
    if schedulable_fixed_priority(T[dm_order])
        for (prio, i) in enumerate(dm_order)
            # Assign the same priority to all job-classes of T[i]
            prios[i] = ones(timetype, l[i]) .* prio
        end
    else
        for i in dm_order
            prios[i] = zeros(timetype, l[i])
        end
        L = maximum(l)
        for q in 1:L
            if q > 1
                # Sort T in ascending order of w_i and deadline
                dm_order = sort(axes(T, 1), by=i->(miss_threshold(T[i]), deadline(T[i])))
            end
            for i in dm_order
                if q <= l[i]
                    prios[i][q] = prio
                    prio += 1
                end
            end
        end
    end
    prios
end

"""
    low_index_first_hold(T::AbstractRealTimeTaskSystem)

Compute priorities for each job-class of each task in T according to the low-index
job-class first with priority holding mechanism (LIF-h) heuristic.
"""
function low_index_first_hold(T::AbstractRealTimeTaskSystem)
    prio = low_index_first(T)
    if schedulable_jcl(T, prio)
        return prio
    end
    idx = 1
    for (i, τ) in enumerate(T)
        c = constraint(τ)
        l = length(prio[i])
        h = Int(ceil(c.meet / (c.window - c.meet)))
        while idx < l
            for q in idx:min(idx+h, l)
                prio[i][q] = prio[i][idx]
            end
            idx += h
        end
    end
    prio
end

"""
    wcrt_jcl(T, prio)

Compute worst-case response times (WCRTs) for each job-class in task system `T`, with the
given job-class priorities `prio`.
"""
function wcrt_jcl(T::AbstractRealTimeTaskSystem, prio)
    wcrt = zero.(prio)
    η = zero.(prio)
    # Vector of (task index, job-class index, job-class priority)
    jcp = map(x->(x[1], x[2][1], x[2][2]),
              Iterators.flatten(map(x->Iterators.zip(Iterators.cycle(x[1]), x[2]),
                                    enumerate(enumerate.(prio)))))
    # Sort by job-class priority
    sort!(jcp, by=x->x[3])
    for (i, q, πiq) in jcp
        Riq = cost(T[i])
        Riq_prev = 0
        # While not at fixed point
        while Riq > Riq_prev
            Riq_prev = Riq
            Wiq = 0
            # For each task
            for k in eachindex(T)
                v = 0
                # If it's not the task we're currently analyzing
                if k != i
                    # For each job-class
                    for (p, πkp) in enumerate(prio[k])
                        # If it's higher priority
                        if πkp < πiq
                            # If that job-class always completes on time
                            if wcrt[k][p] <= deadline(T[k])
                                if p == 1
                                    η[k][p] = (miss_threshold(T[k]) + 1) * period(T[k])
                                elseif q > 1
                                    η[k][p] = (p + 2) * period(T[k])
                                end
                            # If that job-class may miss
                            else
                                if miss_threshold(T[k]) == 1
                                    η[k][p] = (p + 1) * period(T[k])
                                elseif miss_threshold(T[k]) > 1
                                    η[k][p] = period(T[k])
                                end
                            end
                            # If it's the highest-index job-class
                            if p == constraint(T[k]).meet + 1
                                η[k][p] = period(T[k])
                            end
                            v += ceil(Riq_prev / η[k][p]) * cost(T[k])
                        end
                    end
                end
                Wiq += min(v, ceil(Riq_prev / period(T[k])) * cost(T[k]))
            end
            Riq = cost(T[i]) + Wiq
        end
        wcrt[i][q] = Riq
    end
    wcrt
end

"""
    schedulable_jcl(T, prio)

Check if the [`AbstractRealTimeTaskSystem`](@ref) `T` is schedulable by job-class-level
scheduling with the job-class priorities given by `prio`.
"""
function schedulable_jcl(T::AbstractRealTimeTaskSystem, prio)
    wcrt = wcrt_jcl(T, prio)
    # Lemma 9: The first job-class of each task must have WCRT <= deadline
    all(((τ, w),) -> w[1] <= deadline(τ), zip(T, wcrt)) || return false

    # Helper function for recursive tree search
    function tree(τ::PeriodicWeaklyHardTask, wcrt, μ::BitVector, C)
        # For leaf nodes, return whether their μ-pattern satisfies the constraint
        if length(μ) == constraint(τ).window
            return μ ⊢ constraint(τ)
        end
        # Lemma 11: A node from its parent's miss branch generates a single meet branch
        if !μ[end]
            return tree(τ, wcrt, [μ; true], [C; 2])
        end
        meet_C = min(length(wcrt), C[end]+1)
        if length(C) > 1 && wcrt[C[end-1]] <= deadline(τ) && wcrt[C[end]] <= deadline(τ)
            return tree(τ, wcrt, [μ; true], [C; meet_C])
        else
            return (tree(τ, wcrt, [μ; true], [C; meet_C])
                    && tree(τ, wcrt, [μ; false], [C; 1]))
        end
    end

    # Check schedulability of each task
    for (i, τ) in enumerate(T)
        # Lemma 10: A task is schedulable if miss/window >= 1/2 and Lemma 9 holds
        c = constraint(τ)
        if (c.meet - c.window) / c.window >= 1/2
            continue
        end
        # If all job-classes complete by the deadline, the task can never miss
        if all(wcrt[i] .<= deadline(τ))
            continue
        end
        # The trees generate only strings with no more than one miss in any window of
        # length two.  Thus, this constant time check is sufficient, but not necessary.
        if MeetAny(1, 2) <= c
            continue
        end
        # Check that all trees have feasible leaves
        for q in eachindex(wcrt[i])
            tree(τ, wcrt[i], BitVector([q != 1]), [q]) || return false
        end
    end
    true
end

end
