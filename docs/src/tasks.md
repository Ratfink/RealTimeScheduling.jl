# Tasks

RealTimeScheduling provides several different representations of real-time
tasks.  These include periodic tasks with implicit or explicit deadlines.

```@docs
AbstractRealTimeTask
PeriodicTask
PeriodicImplicitTask
```

The task types can be converted to one another automatically, and
[`PeriodicImplicitTask`](@ref) objects can also be promoted to
[`PeriodicTask`](@ref) when required (e.g. when putting both types of task into
a single [`TaskSystem`](@ref)).

## Task Attributes

Of course, methods are provided to get a task's period, relative deadline, and
execution cost.

```@docs
period
deadline
cost
```

Utilization and density can be computed easily as well.

```@docs
utilization(::AbstractRealTimeTask)
density(::AbstractRealTimeTask)
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