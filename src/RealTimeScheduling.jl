module RealTimeScheduling

export AbstractRealTimeTask,
       PeriodicTask,
       PeriodicImplicitTask,
       period,
       deadline,
       cost,
       implicit_deadline,
       constrained_deadline,
       utilization,
       density,
       feasible,
       demand_bound,
       request_bound,
       # Task systems
       AbstractRealTimeTaskSystem,
       TaskSystem,
       rate_monotonic!,
       deadline_monotonic!,
       # Weakly-hard constraints
       WeaklyHardConstraint,
       MeetAny,
       MeetRow,
       MissAny,
       MissRow,
       SamplerMissRow,
       # Schedulability tests
       schedulable_fixed_priority
include("tasks.jl")
include("tasksystems.jl")
include("weaklyhard.jl")
include("schedulability.jl")

end
