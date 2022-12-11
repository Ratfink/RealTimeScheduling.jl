# Task Systems

For interesting schedulability problems, a set of tasks needs to be contained
within a *task system*.  RealTimeScheduling provides such a type, which is a
fairly thin wrapper around a standard `Vector`.

```@docs
AbstractRealTimeTaskSystem
TaskSystem
```

## Generating Task Systems

Task systems can be generated at random using common algorithms from the
real-time literature.  This is useful for conducting schedulability studies.

```@docs
randtasksystem
```

## Testing Properties of Task Systems

As with individual tasks, it can be useful to check if *all* tasks in a task
system are implicit or constrained deadline.

```@docs
implicit_deadline(::AbstractRealTimeTaskSystem)
constrained_deadline(::AbstractRealTimeTaskSystem)
```

It's just as easy to compute the utilization or density of a task system, as
well as its hyperperiod.

```@docs
utilization(::AbstractRealTimeTaskSystem)
density(::AbstractRealTimeTaskSystem)
min_utilization(::AbstractRealTimeTaskSystem)
min_density(::AbstractRealTimeTaskSystem)
hyperperiod(::AbstractRealTimeTaskSystem)
```

Additionally, it's often a sensible check to verify that a task system is
feasible before doing other tests on it.

```@docs
feasible(::AbstractRealTimeTaskSystem)
```

## Task Priority

For fixed-priority (FP) scheduling, RealTimeScheduling uses an implicit model of
task priority, whereby the index of a task in a given [`TaskSystem`](@ref) *is*
its priority.  Lower indices are considered higher priority, as is usually the
case in the literature.

We provide two functions to sort a [`TaskSystem`](@ref) in order of increasing
period and relative deadline.

```@docs
rate_monotonic!
deadline_monotonic!
```

## Time-Demand Analysis

Many schedulability tests make use of time-demand analysis (TDA).  To support
this, the common demand bound function (DBF) and request bound function (RBF)
are implemented for task systems.

```@docs
demand_bound(::AbstractRealTimeTaskSystem, ::Real)
request_bound(::AbstractRealTimeTaskSystem, ::Real)
```

Using the RBF, the package provides an implementation of TDA for uniprocessor
fixed-priority task systems.

```@docs
schedulable_fixed_priority
```
