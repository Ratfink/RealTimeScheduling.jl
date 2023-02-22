"""
An implementation of the scheduler and schedulability test from the paper "Toward Practical
Weakly Hard Real-Time Systems: A Job-Class-Level Scheduling Approach" by Choi, Kim, and Zhu.
DOI: [10.1109/JIOT.2021.3058215](https://doi.org/10.1109/JIOT.2021.3058215)
"""
module JobClassLevelScheduling

using ...RealTimeScheduling

export schedule_jcl,
       miss_threshold


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
miss_threshold(τ::PeriodicWeaklyHardTask{<:Real, MeetAny}) = miss_threshold(constraint(τ))

end
