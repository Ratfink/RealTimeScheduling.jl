module RealTimeScheduling

export AbstractRealTimeTask,
       PeriodicTask,
       PeriodicImplicitTask,
       PeriodicWeaklyHardTask,
       period,
       deadline,
       cost,
       constraint,
       implicit_deadline,
       constrained_deadline,
       utilization,
       density,
       min_utilization,
       min_density,
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
       HardRealTime,
       BestEffort,
       SamplerUniformMissRow,
       # Schedulability tests
       schedulable_fixed_priority
include("weaklyhard.jl")
include("tasks.jl")
include("tasksystems.jl")
include("schedulability.jl")

end
