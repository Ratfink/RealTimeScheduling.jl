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
        task_index = Int(j.priority)
        q = 0 # TODO compute job-class of job j
        j.priority = prio[task_index][q]
    end
end

"""
    miss_threshold(c::MeetAny)

Compute the miss threshold ``w_i`` for the given [`MeetAny`](@ref) constraint.
"""
miss_threshold(c::MeetAny) = max(floor(c.window / c.meet) - 1, 1)

"""
    miss_threshold(τ::PeriodicWeaklyHardTask{<:Real, MeetAny})

Compute the miss threshold ``w_i`` for the given weakly hard task.
"""
miss_threshold(τ::PeriodicWeaklyHardTask{<:Real, MeetAny}) = miss_threshold(constraint(τ))

end
