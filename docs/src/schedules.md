# Scheduling

RealTimeScheduling implements a simple yet flexible scheduling simulator
supporting preemptive global job-level fixed priority scheduling of
[`TaskSystem`](@ref) structs.  It also supports generating plots of the
resulting schedules using the [Plots.jl](https://docs.juliaplots.org/stable/)
package.

```@example
using RealTimeScheduling, Plots
T = TaskSystem([PeriodicImplicitTask(3, 2), PeriodicImplicitTask(3, 2), PeriodicImplicitTask(3, 2)])
s = schedule_gedf(T, 2, 30.)
plot(s, size=(600, 300))
```

```@docs
schedule_global
schedule_gedf
schedule_gfl
schedule_gfp
AbstractSchedule
AbstractTaskSchedule
RealTimeTaskSchedule
RealTimeTaskSchedule(::Type, ::AbstractRealTimeTaskSystem)
```

## Concrete Jobs

Schedule objects contain a `Vector` of `Vector`s of [`AbstractJob`](@ref)
objects.  These contain all the parameters of a concrete real-time job:
[`release`](@ref), [`deadline`](@ref), [`cost`](@ref), and [`priority`](@ref),
as well as a `Vector` of [`ExecInterval`](@ref) objects.

```@docs
AbstractJob
AbstractJobOfTask
Job
JobOfTask
task(::AbstractJobOfTask)
release(::AbstractJob)
deadline(::AbstractJob)
cost(::AbstractJob)
priority(::AbstractJob)
exec(::AbstractJob)
exectime(::AbstractJob)
completed(::AbstractJob)
completiontime(::AbstractJob)
responsetime(::AbstractJob)
ExecInterval
```
