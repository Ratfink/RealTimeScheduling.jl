# Job-Class-Level Scheduling

The module `RealTimeScheduling.Papers.JobClassLevelScheduling` implements the 
scheduler and schedulability test from the paper "Toward Practical Weakly Hard
Real-Time Systems: A Job-Class-Level Scheduling Approach" by Choi, Kim, and Zhu.
DOI: [10.1109/JIOT.2021.3058215](https://doi.org/10.1109/JIOT.2021.3058215).
The scheduler from this paper divides jobs of each task into job-classes on the
basis of the length of the most recent sequence of consecutive deadline hits,
and assigns each job-class of each task a fixed priority.  This enables the
scheduling of weakly hard task systems that are infeasible with any task-level
fixed priority scheduler.

```@docs
RealTimeScheduling.Papers.JobClassLevelScheduling.schedule_jcl
RealTimeScheduling.Papers.JobClassLevelScheduling.miss_threshold
```
