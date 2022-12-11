# RealTimeScheduling.jl

*Real-time systems modeling and schedulability analysis*

This package aims to provide useful tools for writing schedulability studies
with Julia.  It provides basic functionality for schedulability testing,
response time analysis, schedule simulation, and schedule plotting.
It is inspired by [SchedCAT](https://github.com/brandenburg/schedcat) by Björn
Brandenburg, but is not a direct port since Julia isn't Python. 😉

## Example

As a simple example, one can perform analysis of Example 3 from John Lehoczky,
"Fixed priority scheduling of periodic task sets with arbitrary deadlines,"
RTSS 1990.
DOI: [10.1109/REAL.1990.128748](https://doi.org/10.1109/REAL.1990.128748)

In this example, we consider two tasks: one with period $T_1 = 70$ and cost
$C_1 = 26$, and another with period $T_2 = 100$ and cost $C_2 = 62$.  These
tasks have an interesting behavior when scheduled by rate-monotonic fixed
priority scheduling.

```@example lehoczky_3
using RealTimeScheduling
ex3 = TaskSystem([PeriodicTask(70, 70, 26), PeriodicTask(100, 100, 62)])
schedulable_fixed_priority(ex3)
```

As can be seen, the tasks are not schedulable with implicit deadlines.
However, increasing the deadline of task 2 makes the system schedulable.

```@example lehoczky_3
ex3[2] = PeriodicTask(100, 118, 62)
schedulable_fixed_priority(ex3)
```

To get a better idea of what's going on here, we can compute a schedule to the
hyperperiod of the tasks, and plot it.

```@example lehoczky_3
s = schedule_gfp(ex3, 1, hyperperiod(ex3))
using Plots
plot(s, size=(800, 200), xguide="", yguide="")
```

The response time of the second task varies non-monotonically across its jobs,
with the fifth job having the maximum response time of 118.  This clearly
motivates the need to examine the entire hyperperiod when testing fixed
priority schedulability of task systems with unconstrained deadlines.
