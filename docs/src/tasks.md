# Tasks

RealTimeScheduling provides several different representations of real-time
tasks.  These include periodic tasks with implicit or explicit deadlines.
Periodic tasks with weakly hard constraints are also supported.

```@docs
AbstractRealTimeTask
PeriodicTask
PeriodicImplicitTask
PeriodicWeaklyHardTask
```

The task types can be converted to one another automatically, and
[`PeriodicImplicitTask`](@ref) objects can also be promoted to
[`PeriodicTask`](@ref) when required (e.g. when putting both types of task into
a single [`TaskSystem`](@ref)).

## Task Attributes

Of course, methods are provided to get a task's period, relative deadline, and
execution cost.

```@docs
period(::AbstractRealTimeTask)
deadline(::AbstractRealTimeTask)
cost(::AbstractRealTimeTask)
```

Utilization and density can be computed easily as well.

```@docs
utilization(::AbstractRealTimeTask)
density(::AbstractRealTimeTask)
```

For weakly hard tasks, the minimum utilization and density may also be
computed, multiplying the utilization and density by the maximum fraction of
jobs that can be missed in an unbounded time horizon.

```@docs
min_utilization(::PeriodicWeaklyHardTask)
min_density(::PeriodicWeaklyHardTask)
```

## Testing Properties of Tasks

Sometimes it's useful to know how the deadline of a task relates to its period.
RealTimeScheduling provides two functions for this.

```@docs
implicit_deadline(::AbstractRealTimeTask)
constrained_deadline(::AbstractRealTimeTask)
```

Additionally, it's often important to know if a task's cost exceeds its period.

```@docs
feasible(::AbstractRealTimeTask)
```

## Time-Demand Analysis

Many schedulability tests make use of time-demand analysis (TDA).  To support
this, the common demand bound function (DBF) and request bound function (RBF)
are implemented.

```@docs
demand_bound(::AbstractRealTimeTask, ::Real)
request_bound(::AbstractRealTimeTask, ::Real)
```
