var documenterSearchIndex = {"docs":
[{"location":"weaklyhard/#Weakly-Hard-Systems","page":"Weakly Hard Systems","title":"Weakly Hard Systems","text":"","category":"section"},{"location":"weaklyhard/","page":"Weakly Hard Systems","title":"Weakly Hard Systems","text":"RealTimeScheduling provides basic support for weakly hard constraints.","category":"page"},{"location":"weaklyhard/","page":"Weakly Hard Systems","title":"Weakly Hard Systems","text":"warning: Warning\nSupport for weakly hard systems is still a work in progress, and the API is still very incomplete.  For now, we mainly support the constraints themselves, as well as comparisons between them.","category":"page"},{"location":"weaklyhard/","page":"Weakly Hard Systems","title":"Weakly Hard Systems","text":"Constraints that are logically equivalent compare as equal, even if they are represented differently.","category":"page"},{"location":"weaklyhard/","page":"Weakly Hard Systems","title":"Weakly Hard Systems","text":"julia> MeetAny(1, 1) == MeetRow(3, 5) == MissRow(0) == HardRealTime()\ntrue\n\njulia> MeetRow(0, 0) == MeetAny(0, 0) == BestEffort()\ntrue\n\njulia> MeetRow(4, 5) == MeetRow(2, 5)\nfalse","category":"page"},{"location":"weaklyhard/","page":"Weakly Hard Systems","title":"Weakly Hard Systems","text":"Testing whether a BitVector satisfies a WeaklyHardConstraint is supported.","category":"page"},{"location":"weaklyhard/","page":"Weakly Hard Systems","title":"Weakly Hard Systems","text":"julia> BitVector([0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1]) ⊢ MeetRow(2, 5)\ntrue\n\njulia> BitVector([0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1]) ⊢ MeetRow(2, 5)\nfalse","category":"page"},{"location":"weaklyhard/","page":"Weakly Hard Systems","title":"Weakly Hard Systems","text":"WeaklyHardConstraint\nMeetAny\nMissAny\nMeetRow\nMissRow\nHardRealTime\nBestEffort\nsatisfies\n⊢\n⊬","category":"page"},{"location":"weaklyhard/#RealTimeScheduling.WeaklyHardConstraint","page":"Weakly Hard Systems","title":"RealTimeScheduling.WeaklyHardConstraint","text":"Abstract parent type of all weakly hard constraints\n\nThe concrete subtypes of this, and many of the methods defined on them, are due to Bernat, Burns, and Llamosí, \"Weakly Hard Real-Time Systems,\" IEEE Trans. Computers, Vol. 50, No. 4, April 2001.\n\n\n\n\n\n","category":"type"},{"location":"weaklyhard/#RealTimeScheduling.MeetAny","page":"Weakly Hard Systems","title":"RealTimeScheduling.MeetAny","text":"MeetAny{T}(meet::T, window::T)\n\nWeakly hard constraint specifying that a task meets meet deadlines in any window of size window.  Must satisfy 0 <= meet <= window.\n\n\n\n\n\n","category":"type"},{"location":"weaklyhard/#RealTimeScheduling.MissAny","page":"Weakly Hard Systems","title":"RealTimeScheduling.MissAny","text":"MissAny([T=Int, ]miss, window)\n\nConstruct a MeetAny{T} constraint that allows at most miss deadlines to be missed in any window of size window.\n\nWhile constraints of this sort are often expressed as a different type in the literature, they are equivalent to MeetAny, so using a single type simplifies any code using weakly hard constraints.\n\n\n\n\n\n","category":"function"},{"location":"weaklyhard/#RealTimeScheduling.MeetRow","page":"Weakly Hard Systems","title":"RealTimeScheduling.MeetRow","text":"MeetRow{T}(meet::T, window::T)\n\nWeakly hard constraint specifying that a task meets meet deadlines in a row in any window of size window.  Must satisfy 0 <= meet <= window.\n\n\n\n\n\n","category":"type"},{"location":"weaklyhard/#RealTimeScheduling.MissRow","page":"Weakly Hard Systems","title":"RealTimeScheduling.MissRow","text":"MissRow{T}(miss::T)\n\nWeakly hard constraint specifying that a task misses at most miss deadlines in a row. Must satisfy 0 <= miss.\n\n\n\n\n\n","category":"type"},{"location":"weaklyhard/#RealTimeScheduling.HardRealTime","page":"Weakly Hard Systems","title":"RealTimeScheduling.HardRealTime","text":"HardRealTime{T}()\n\nWeakly hard constraint specifying that no deadlines may be missed.\n\n\n\n\n\n","category":"type"},{"location":"weaklyhard/#RealTimeScheduling.BestEffort","page":"Weakly Hard Systems","title":"RealTimeScheduling.BestEffort","text":"BestEffort{T}()\n\nWeakly hard constraint specifying that any pattern of deadline misses is acceptable.\n\n\n\n\n\n","category":"type"},{"location":"weaklyhard/#RealTimeScheduling.satisfies","page":"Weakly Hard Systems","title":"RealTimeScheduling.satisfies","text":"satisfies(bv::BitVector, c::WeaklyHardConstraint)\n⊢(bv::BitVector, c::WeaklyHardConstraint)\n\nCheck that the BitVector bv satisfies the weakly hard constraint given by c.\n\n\n\n\n\n","category":"function"},{"location":"weaklyhard/#RealTimeScheduling.:⊢","page":"Weakly Hard Systems","title":"RealTimeScheduling.:⊢","text":"satisfies(bv::BitVector, c::WeaklyHardConstraint)\n⊢(bv::BitVector, c::WeaklyHardConstraint)\n\nCheck that the BitVector bv satisfies the weakly hard constraint given by c.\n\n\n\n\n\n\n\n","category":"function"},{"location":"weaklyhard/#RealTimeScheduling.:⊬","page":"Weakly Hard Systems","title":"RealTimeScheduling.:⊬","text":"⊬(bv::BitVector, c::WeaklyHardConstraint)\n\nCheck that the BitVector bv does not satisfy the weakly hard constraint given by c.\n\n\n\n\n\n","category":"function"},{"location":"weaklyhard/#Sampling-from-Weakly-Hard-Constraints","page":"Weakly Hard Systems","title":"Sampling from Weakly Hard Constraints","text":"","category":"section"},{"location":"weaklyhard/","page":"Weakly Hard Systems","title":"Weakly Hard Systems","text":"A weakly hard constraint can be viewed as a sample space of bit strings, with 0 representing a deadline miss, and 1 representing a deadline hit.  A finite length must be provided to generate such a string.  For now, we only support uniform sampling from MissRow constraints.","category":"page"},{"location":"weaklyhard/","page":"Weakly Hard Systems","title":"Weakly Hard Systems","text":"Unfortunately, the requirement of specifying a string length precludes the easiest use of the Random.rand API.  However, the precomputation required is non-negligible, so it would be a good idea to first create a sampler anyway.","category":"page"},{"location":"weaklyhard/","page":"Weakly Hard Systems","title":"Weakly Hard Systems","text":"SamplerUniformMissRow","category":"page"},{"location":"weaklyhard/#RealTimeScheduling.SamplerUniformMissRow","page":"Weakly Hard Systems","title":"RealTimeScheduling.SamplerUniformMissRow","text":"SamplerUniformMissRow(constraint::MissRow, H::Int64)\n\nPre-compute data for uniformly sampling BitVector objects from a MissRow constraint.  The sampled vectors will have length H.\n\nThe algorithm used is due to Bernardi, Olivier, and Omer Giménez, \"A linear algorithm for the random sampling from regular languages.\" Algorithmica 62.1 (2012): 130-145.\n\nExamples\n\njulia> sp = SamplerUniformMissRow(MissRow(3), 10);\n\njulia> rand(sp)\n10-element BitVector:\n1\n1\n0\n1\n1\n0\n1\n0\n0\n1\n\n\n\n\n\n","category":"type"},{"location":"tasks/#Tasks","page":"Tasks","title":"Tasks","text":"","category":"section"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"RealTimeScheduling provides several different representations of real-time tasks.  These include periodic tasks with implicit or explicit deadlines. Periodic tasks with weakly hard constraints are also supported.","category":"page"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"AbstractRealTimeTask\nPeriodicTask\nPeriodicImplicitTask\nPeriodicWeaklyHardTask","category":"page"},{"location":"tasks/#RealTimeScheduling.AbstractRealTimeTask","page":"Tasks","title":"RealTimeScheduling.AbstractRealTimeTask","text":"Abstract parent type of all real-time task types\n\n\n\n\n\n","category":"type"},{"location":"tasks/#RealTimeScheduling.PeriodicTask","page":"Tasks","title":"RealTimeScheduling.PeriodicTask","text":"PeriodicTask{S}(period::S, deadline::S, cost::S)\n\nConcrete type for periodic real-time tasks.\n\n\n\n\n\n","category":"type"},{"location":"tasks/#RealTimeScheduling.PeriodicImplicitTask","page":"Tasks","title":"RealTimeScheduling.PeriodicImplicitTask","text":"PeriodicImplicitTask{S}(period::S, cost::S)\n\nConcrete type for periodic real-time tasks with implicit deadline.\n\n\n\n\n\n","category":"type"},{"location":"tasks/#RealTimeScheduling.PeriodicWeaklyHardTask","page":"Tasks","title":"RealTimeScheduling.PeriodicWeaklyHardTask","text":"PeriodicWeaklyHardTask{S, R}(period::S, deadline::S, cost::S, constraint::R)\n\nConcrete type for periodic tasks with a weakly hard constraint.\n\n\n\n\n\n","category":"type"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"The task types can be converted to one another automatically, and PeriodicImplicitTask objects can also be promoted to PeriodicTask when required (e.g. when putting both types of task into a single TaskSystem).","category":"page"},{"location":"tasks/#Task-Attributes","page":"Tasks","title":"Task Attributes","text":"","category":"section"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"Of course, methods are provided to get a task's period, relative deadline, and execution cost.","category":"page"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"period(::AbstractRealTimeTask)\ndeadline(::AbstractRealTimeTask)\ncost(::AbstractRealTimeTask)","category":"page"},{"location":"tasks/#RealTimeScheduling.period-Tuple{AbstractRealTimeTask}","page":"Tasks","title":"RealTimeScheduling.period","text":"period(τ::AbstractRealTimeTask)\n\nReturn the period of the real-time task τ.\n\n\n\n\n\n","category":"method"},{"location":"tasks/#RealTimeScheduling.deadline-Tuple{AbstractRealTimeTask}","page":"Tasks","title":"RealTimeScheduling.deadline","text":"deadline(τ::AbstractRealTimeTask)\n\nReturn the deadline of the real-time task τ.\n\n\n\n\n\n","category":"method"},{"location":"tasks/#RealTimeScheduling.cost-Tuple{AbstractRealTimeTask}","page":"Tasks","title":"RealTimeScheduling.cost","text":"cost(τ::AbstractRealTimeTask)\n\nReturn the cost, or worst-case execution time, of the real-time task τ.\n\n\n\n\n\n","category":"method"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"Utilization and density can be computed easily as well.","category":"page"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"utilization(::AbstractRealTimeTask)\ndensity(::AbstractRealTimeTask)","category":"page"},{"location":"tasks/#RealTimeScheduling.utilization-Tuple{AbstractRealTimeTask}","page":"Tasks","title":"RealTimeScheduling.utilization","text":"utilization(τ::AbstractRealTimeTask)\n\nCompute the utilization of real-time task τ, cost/period.\n\nSee also density.\n\n\n\n\n\n","category":"method"},{"location":"tasks/#RealTimeScheduling.density-Tuple{AbstractRealTimeTask}","page":"Tasks","title":"RealTimeScheduling.density","text":"density(τ::AbstractRealTimeTask)\n\nCompute the density of real-time task τ, cost/min(period, deadline).\n\nSee also utilization.\n\n\n\n\n\n","category":"method"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"For weakly hard tasks, the minimum utilization and density may also be computed, multiplying the utilization and density by the maximum fraction of jobs that can be missed in an unbounded time horizon.","category":"page"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"min_utilization(::PeriodicWeaklyHardTask)\nmin_density(::PeriodicWeaklyHardTask)","category":"page"},{"location":"tasks/#RealTimeScheduling.min_utilization-Tuple{PeriodicWeaklyHardTask}","page":"Tasks","title":"RealTimeScheduling.min_utilization","text":"min_utilization(τ::PeriodicWeaklyHardTask)\n\nCompute the minimum utilization of weakly hard real-time task τ, representing the utilization of the task if as few jobs as possible are executed.\n\nSee also utilization, density, and min_density.\n\n\n\n\n\n","category":"method"},{"location":"tasks/#RealTimeScheduling.min_density-Tuple{PeriodicWeaklyHardTask}","page":"Tasks","title":"RealTimeScheduling.min_density","text":"min_density(τ::PeriodicWeaklyHardTask)\n\nCompute the minimum density of weakly hard real-time task τ, representing the density of the task if as few jobs as possible are executed.\n\nSee also utilization, density, and min_utilization.\n\n\n\n\n\n","category":"method"},{"location":"tasks/#Testing-Properties-of-Tasks","page":"Tasks","title":"Testing Properties of Tasks","text":"","category":"section"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"Sometimes it's useful to know how the deadline of a task relates to its period. RealTimeScheduling provides two functions for this.","category":"page"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"implicit_deadline(::AbstractRealTimeTask)\nconstrained_deadline(::AbstractRealTimeTask)","category":"page"},{"location":"tasks/#RealTimeScheduling.implicit_deadline-Tuple{AbstractRealTimeTask}","page":"Tasks","title":"RealTimeScheduling.implicit_deadline","text":"implicit_deadline(τ::AbstractRealTimeTask)\n\nTest whether the real-time task τ has relative deadline equal to period.\n\n\n\n\n\n","category":"method"},{"location":"tasks/#RealTimeScheduling.constrained_deadline-Tuple{AbstractRealTimeTask}","page":"Tasks","title":"RealTimeScheduling.constrained_deadline","text":"constrained_deadline(τ::AbstractRealTimeTask)\n\nTest whether the real-time task τ has relative deadline at most period.\n\n\n\n\n\n","category":"method"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"Additionally, it's often important to know if a task's cost exceeds its period.","category":"page"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"feasible(::AbstractRealTimeTask)","category":"page"},{"location":"tasks/#RealTimeScheduling.feasible-Tuple{AbstractRealTimeTask}","page":"Tasks","title":"RealTimeScheduling.feasible","text":"feasible(τ::AbstractRealTimeTask)\n\nTest whether the real-time task τ is feasible, i.e. its density is at most 1.\n\n\n\n\n\n","category":"method"},{"location":"tasks/#Time-Demand-Analysis","page":"Tasks","title":"Time-Demand Analysis","text":"","category":"section"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"Many schedulability tests make use of time-demand analysis (TDA).  To support this, the common demand bound function (DBF) and request bound function (RBF) are implemented.","category":"page"},{"location":"tasks/","page":"Tasks","title":"Tasks","text":"demand_bound(::AbstractRealTimeTask, ::Real)\nrequest_bound(::AbstractRealTimeTask, ::Real)","category":"page"},{"location":"tasks/#RealTimeScheduling.demand_bound-Tuple{AbstractRealTimeTask, Real}","page":"Tasks","title":"RealTimeScheduling.demand_bound","text":"demand_bound(τ::AbstractRealTimeTask, t)\n\nCompute Baruah's demand bound function (DBF) for the task τ.\n\nmaxleft(0 leftlfloor fract - mathrmdeadline(τ)mathrmperiod(τ) + 1 rightrfloor mathrmcost(τ) right)\n\n\n\n\n\n","category":"method"},{"location":"tasks/#RealTimeScheduling.request_bound-Tuple{AbstractRealTimeTask, Real}","page":"Tasks","title":"RealTimeScheduling.request_bound","text":"request_bound(τ::AbstractRealTimeTask, t)\n\nCompute the request bound function (RBF) for the task τ.\n\nleftlceil fractmathrmperiod(τ)rightrceil mathrmcost(τ)\n\n\n\n\n\n","category":"method"},{"location":"responsetime/#Response-Time-Analysis","page":"Response Time Analysis","title":"Response Time Analysis","text":"","category":"section"},{"location":"responsetime/","page":"Response Time Analysis","title":"Response Time Analysis","text":"RealTimeScheduling supports calculating response time and tardiness bounds for task systems under global earliest deadline first (GEDF) scheduling.  Multiple algorithms are supported, as shown below.","category":"page"},{"location":"responsetime/","page":"Response Time Analysis","title":"Response Time Analysis","text":"julia> T = TaskSystem([PeriodicImplicitTask(3, 2), PeriodicImplicitTask(3, 2), PeriodicImplicitTask(6, 4)]);\n\njulia> tardiness_gedf(T, 2, GEDFDeviAnderson)\n3-element Vector{Float64}:\n 3.0\n 3.0\n 5.0\n\njulia> tardiness_gedf(T, 2, GEDFCompliantVector)\n3-element Vector{Float64}:\n 3.0\n 3.0\n 4.0","category":"page"},{"location":"responsetime/","page":"Response Time Analysis","title":"Response Time Analysis","text":"Intuitively, increasing the number of processors results in lower response time bounds for the same task system.","category":"page"},{"location":"responsetime/","page":"Response Time Analysis","title":"Response Time Analysis","text":"julia> tardiness_gedf(T, 3, GEDFDeviAnderson)\n3-element Vector{Float64}:\n 2.6666666666666665\n 2.6666666666666665\n 4.666666666666667\n\njulia> tardiness_gedf(T, 3, GEDFCompliantVector)\n3-element Vector{Float64}:\n 2.6666666666666665\n 2.6666666666666665\n 4.0","category":"page"},{"location":"responsetime/","page":"Response Time Analysis","title":"Response Time Analysis","text":"tardiness_gedf\nresponse_time_gedf\nGEDFDeviAnderson\nGEDFCompliantVector","category":"page"},{"location":"responsetime/#RealTimeScheduling.tardiness_gedf","page":"Response Time Analysis","title":"RealTimeScheduling.tardiness_gedf","text":"tardiness_gedf(T, m, ::GEDFDeviAndersonAlg)\n\nCompute tardiness bounds for each task in the TaskSystem T under GEDF scheduling on m processors, according to the GEDFDeviAnderson algorithm.\n\n\n\n\n\ntardiness_gedf(T, m, ::GEDFCompliantVectorAlg)\n\nCompute tardiness bounds for each task in the TaskSystem T under GEDF scheduling on m processors, according to the GEDFCompliantVector algorithm.\n\n\n\n\n\n","category":"function"},{"location":"responsetime/#RealTimeScheduling.response_time_gedf","page":"Response Time Analysis","title":"RealTimeScheduling.response_time_gedf","text":"response_time_gedf(T, m, alg)\n\nCompute response time bounds for each task in the TaskSystem T under GEDF scheduling on m processors, according to the specified algorithm.\n\n\n\n\n\n","category":"function"},{"location":"responsetime/#RealTimeScheduling.GEDFDeviAnderson","page":"Response Time Analysis","title":"RealTimeScheduling.GEDFDeviAnderson","text":"GEDFDeviAnderson\n\nIndicate that a response time bound should be computed according to Devi and Anderson, \"Tardiness Bounds under Global EDF Scheduling on a Multiprocessor.\" DOI: https://doi.org/10.1007/s11241-007-9042-1\n\n\n\n\n\n","category":"constant"},{"location":"responsetime/#RealTimeScheduling.GEDFCompliantVector","page":"Response Time Analysis","title":"RealTimeScheduling.GEDFCompliantVector","text":"GEDFCompliantVector\n\nIndicate that a response time bound should be computed according to Erickson, \"Managing Tardiness Bounds and Overload in Soft Real-Time Systems.\" ISBN: 978-1-321-14155-9\n\n\n\n\n\n","category":"constant"},{"location":"schedules/#Scheduling","page":"Scheduling","title":"Scheduling","text":"","category":"section"},{"location":"schedules/","page":"Scheduling","title":"Scheduling","text":"RealTimeScheduling implements a simple yet flexible scheduling simulator supporting preemptive global job-level fixed priority scheduling of TaskSystem structs.  It also supports generating plots of the resulting schedules using the Plots.jl package.","category":"page"},{"location":"schedules/","page":"Scheduling","title":"Scheduling","text":"using RealTimeScheduling, Plots\nT = TaskSystem([PeriodicImplicitTask(3, 2), PeriodicImplicitTask(3, 2), PeriodicImplicitTask(3, 2)])\ns = schedule_gedf(T, 2, 30.)\nplot(s)","category":"page"},{"location":"schedules/","page":"Scheduling","title":"Scheduling","text":"schedule_global\nschedule_gedf\nschedule_gfp\nAbstractSchedule\nAbstractTaskSchedule\nRealTimeTaskSchedule\nRealTimeTaskSchedule(::Type, ::AbstractRealTimeTaskSystem)","category":"page"},{"location":"schedules/#RealTimeScheduling.schedule_global","page":"Scheduling","title":"RealTimeScheduling.schedule_global","text":"schedule_global(release!, T, m, endtime)\n\nSimulate a preemptive global schedule of task system T on m processors to the specified endtime.  When releasing a job, the function release!(job) is called, allowing arbitrary modifications to be made, enabling a wide variety of global schedulers to be implemented.  Two common examples are provided: schedule_gfp and schedule_gedf.\n\nThe job provided to release!(job) defaults to being released as early as possible (i.e. at time 0 or one period after the task's last job), and has the relative deadline and cost specified by the task.  The priority defaults to the task's index in T, with lower priority values being treated as higher priority by the scheduler.\n\n\n\n\n\n","category":"function"},{"location":"schedules/#RealTimeScheduling.schedule_gedf","page":"Scheduling","title":"RealTimeScheduling.schedule_gedf","text":"schedule_gedf(T, m, time)\n\nSimulate a preemptive global earliest-deadline-first (GEDF) schedule of task system T on m processors for the specified time.\n\nSee also schedule_global for more general global scheduling.\n\n\n\n\n\n","category":"function"},{"location":"schedules/#RealTimeScheduling.schedule_gfp","page":"Scheduling","title":"RealTimeScheduling.schedule_gfp","text":"schedule_gfp(T, m, time)\n\nSimulate a preemptive global fixed priority (GFP) schedule of task system T on m processors for the specified time.  Tasks are prioritized by their index in T, lowest index first.\n\nSee also schedule_global for more general global scheduling.\n\n\n\n\n\n","category":"function"},{"location":"schedules/#RealTimeScheduling.AbstractSchedule","page":"Scheduling","title":"RealTimeScheduling.AbstractSchedule","text":"AbstractSchedule{T}\n\nAbstract supertype for all real-time schedules.\n\n\n\n\n\n","category":"type"},{"location":"schedules/#RealTimeScheduling.AbstractTaskSchedule","page":"Scheduling","title":"RealTimeScheduling.AbstractTaskSchedule","text":"AbstractTaskSchedule{T}\n\nAbstract supertype for all real-time schedules of task systems.\n\n\n\n\n\n","category":"type"},{"location":"schedules/#RealTimeScheduling.RealTimeTaskSchedule","page":"Scheduling","title":"RealTimeScheduling.RealTimeTaskSchedule","text":"RealTimeTaskSchedule{T}(tasks::AbstractRealTimeTaskSystem, jobs::Vector{Vector{T}})\n\nSchedule of a real-time task system.\n\n\n\n\n\n","category":"type"},{"location":"schedules/#RealTimeScheduling.RealTimeTaskSchedule-Tuple{Type, AbstractRealTimeTaskSystem}","page":"Scheduling","title":"RealTimeScheduling.RealTimeTaskSchedule","text":"RealTimeTaskSchedule(T::Type, tasks::AbstractRealTimeTaskSystem)\n\nCreate a RealTimeTaskSchedule{T} with an empty job list for each task.\n\n\n\n\n\n","category":"method"},{"location":"schedules/#Concrete-Jobs","page":"Scheduling","title":"Concrete Jobs","text":"","category":"section"},{"location":"schedules/","page":"Scheduling","title":"Scheduling","text":"Schedule objects contain a Vector of Vectors of AbstractJob objects.  These contain all the parameters of a concrete real-time job: release, deadline, cost, and priority, as well as a Vector of ExecInterval objects.","category":"page"},{"location":"schedules/","page":"Scheduling","title":"Scheduling","text":"AbstractJob\nAbstractJobOfTask\nJob\nJobOfTask\ntask(::AbstractJobOfTask)\nrelease(::AbstractJob)\ndeadline(::AbstractJob)\ncost(::AbstractJob)\npriority(::AbstractJob)\nexec\nExecInterval","category":"page"},{"location":"schedules/#RealTimeScheduling.AbstractJob","page":"Scheduling","title":"RealTimeScheduling.AbstractJob","text":"AbstractJob\n\nAbstract supertype for all real-time jobs.\n\n\n\n\n\n","category":"type"},{"location":"schedules/#RealTimeScheduling.AbstractJobOfTask","page":"Scheduling","title":"RealTimeScheduling.AbstractJobOfTask","text":"AbstractJobOfTask{T}\n\nAbstract supertype for all real-time jobs of tasks.\n\n\n\n\n\n","category":"type"},{"location":"schedules/#RealTimeScheduling.Job","page":"Scheduling","title":"RealTimeScheduling.Job","text":"Job{S}(release::S, deadline::S, cost::S, priority::S, exec::Vector{ExecInterval{S}}\n\nA real-time job with the given parameters, executing over the intervals in exec.\n\n\n\n\n\n","category":"type"},{"location":"schedules/#RealTimeScheduling.JobOfTask","page":"Scheduling","title":"RealTimeScheduling.JobOfTask","text":"JobOfTask{S, T}(task::T, release::S, deadline::S, cost::S, priority::S, exec::Vector{ExecInterval{S}}\n\nA real-time job of the given task with the given parameters, executing over the intervals in exec.\n\n\n\n\n\n","category":"type"},{"location":"schedules/#RealTimeScheduling.task-Tuple{AbstractJobOfTask}","page":"Scheduling","title":"RealTimeScheduling.task","text":"task(j::AbstractJobOfTask)\n\nReturn the task associated with job j.\n\n\n\n\n\n","category":"method"},{"location":"schedules/#RealTimeScheduling.release-Tuple{AbstractJob}","page":"Scheduling","title":"RealTimeScheduling.release","text":"release(j::AbstractJob)\n\nReturn the release time of job j.\n\n\n\n\n\n","category":"method"},{"location":"schedules/#RealTimeScheduling.deadline-Tuple{AbstractJob}","page":"Scheduling","title":"RealTimeScheduling.deadline","text":"deadline(j::AbstractJob)\n\nReturn the absolute deadline of job j.\n\n\n\n\n\n","category":"method"},{"location":"schedules/#RealTimeScheduling.cost-Tuple{AbstractJob}","page":"Scheduling","title":"RealTimeScheduling.cost","text":"cost(j::AbstractJob)\n\nReturn the execution cost of job j.\n\n\n\n\n\n","category":"method"},{"location":"schedules/#RealTimeScheduling.priority-Tuple{AbstractJob}","page":"Scheduling","title":"RealTimeScheduling.priority","text":"priority(j::AbstractJob)\n\nReturn the priority of job j.\n\n\n\n\n\n","category":"method"},{"location":"schedules/#RealTimeScheduling.exec","page":"Scheduling","title":"RealTimeScheduling.exec","text":"exec(j::Job)\n\nReturn the execution intervals of job j.\n\n\n\n\n\nexec(j::JobOfTask)\n\nReturn the execution intervals of job j.\n\n\n\n\n\n","category":"function"},{"location":"schedules/#RealTimeScheduling.ExecInterval","page":"Scheduling","title":"RealTimeScheduling.ExecInterval","text":"ExecInterval{S}(start::S, stop::S, proc::Int)\n\nInterval type for job execution, with a specified processor index.  Always assumed to be half open, i.e., [start, stop).\n\n\n\n\n\n","category":"type"},{"location":"tasksystems/#Task-Systems","page":"Task Systems","title":"Task Systems","text":"","category":"section"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"For interesting schedulability problems, a set of tasks needs to be contained within a task system.  RealTimeScheduling provides such a type, which is a fairly thin wrapper around a standard Vector.","category":"page"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"AbstractRealTimeTaskSystem\nTaskSystem","category":"page"},{"location":"tasksystems/#RealTimeScheduling.AbstractRealTimeTaskSystem","page":"Task Systems","title":"RealTimeScheduling.AbstractRealTimeTaskSystem","text":"Abstract parent type of all real-time task system types\n\n\n\n\n\n","category":"type"},{"location":"tasksystems/#RealTimeScheduling.TaskSystem","page":"Task Systems","title":"RealTimeScheduling.TaskSystem","text":"TaskSystem{T} <: AbstractRealTimeTaskSystem\n\nA concrete real-time task system, holding a Vector of tasks of type T.\n\n\n\n\n\n","category":"type"},{"location":"tasksystems/#Generating-Task-Systems","page":"Task Systems","title":"Generating Task Systems","text":"","category":"section"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"Task systems can be generated at random using common algorithms from the real-time literature.  This is useful for conducting schedulability studies.","category":"page"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"randtasksystem","category":"page"},{"location":"tasksystems/#RealTimeScheduling.randtasksystem","page":"Task Systems","title":"RealTimeScheduling.randtasksystem","text":"randtasksystem([tasktype=PeriodicImplicitTask{Float64}], U::Real,\n               utilization_dist::Univariate, period_dist::Univariate)\n\nGenerate a random TaskSystem with utilization at most U.  Tasks are drawn one at a time with utilizations drawn from utilization_dist, and periods from period_dist.  The task system is returned once the next task generated would cause its utilization to exceed U.\n\n\n\n\n\n","category":"function"},{"location":"tasksystems/#Testing-Properties-of-Task-Systems","page":"Task Systems","title":"Testing Properties of Task Systems","text":"","category":"section"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"As with individual tasks, it can be useful to check if all tasks in a task system are implicit or constrained deadline.","category":"page"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"implicit_deadline(::AbstractRealTimeTaskSystem)\nconstrained_deadline(::AbstractRealTimeTaskSystem)","category":"page"},{"location":"tasksystems/#RealTimeScheduling.implicit_deadline-Tuple{AbstractRealTimeTaskSystem}","page":"Task Systems","title":"RealTimeScheduling.implicit_deadline","text":"implicit_deadline(T::AbstractRealTimeTaskSystem)\n\nTest whether all real-time tasks in T are implicit deadline.\n\n\n\n\n\n","category":"method"},{"location":"tasksystems/#RealTimeScheduling.constrained_deadline-Tuple{AbstractRealTimeTaskSystem}","page":"Task Systems","title":"RealTimeScheduling.constrained_deadline","text":"constrained_deadline(T::AbstractRealTimeTaskSystem)\n\nTest whether all real-time tasks in T are constrained deadline.\n\n\n\n\n\n","category":"method"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"It's just as easy to compute the utilization or density of a task system.","category":"page"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"utilization(::AbstractRealTimeTaskSystem)\ndensity(::AbstractRealTimeTaskSystem)\nmin_utilization(::AbstractRealTimeTaskSystem)\nmin_density(::AbstractRealTimeTaskSystem)","category":"page"},{"location":"tasksystems/#RealTimeScheduling.utilization-Tuple{AbstractRealTimeTaskSystem}","page":"Task Systems","title":"RealTimeScheduling.utilization","text":"utilization(T::AbstractRealTimeTaskSystem)\n\nReturn the sum utilization of all tasks in T.\n\n\n\n\n\n","category":"method"},{"location":"tasksystems/#RealTimeScheduling.density-Tuple{AbstractRealTimeTaskSystem}","page":"Task Systems","title":"RealTimeScheduling.density","text":"density(T::AbstractRealTimeTaskSystem)\n\nReturn the sum density of all tasks in T.\n\n\n\n\n\n","category":"method"},{"location":"tasksystems/#RealTimeScheduling.min_utilization-Tuple{AbstractRealTimeTaskSystem}","page":"Task Systems","title":"RealTimeScheduling.min_utilization","text":"min_utilization(T::AbstractRealTimeTaskSystem)\n\nReturn the sum min_utilization of all tasks in T.\n\n\n\n\n\n","category":"method"},{"location":"tasksystems/#RealTimeScheduling.min_density-Tuple{AbstractRealTimeTaskSystem}","page":"Task Systems","title":"RealTimeScheduling.min_density","text":"min_density(T::AbstractRealTimeTaskSystem)\n\nReturn the sum min_density of all tasks in T.\n\n\n\n\n\n","category":"method"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"Additionally, it's often a sensible check to verify that a task system is feasible before doing other tests on it.","category":"page"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"feasible(::AbstractRealTimeTaskSystem)","category":"page"},{"location":"tasksystems/#RealTimeScheduling.feasible-Tuple{AbstractRealTimeTaskSystem}","page":"Task Systems","title":"RealTimeScheduling.feasible","text":"feasible(T::AbstractRealTimeTaskSystem)\n\nTest whether the real-time task system T is feasible, i.e. its density is at most 1.\n\n\n\n\n\n","category":"method"},{"location":"tasksystems/#Task-Priority","page":"Task Systems","title":"Task Priority","text":"","category":"section"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"For fixed-priority (FP) scheduling, RealTimeScheduling uses an implicit model of task priority, whereby the index of a task in a given TaskSystem is its priority.  Lower indices are considered higher priority, as is usually the case in the literature.","category":"page"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"We provide two functions to sort a TaskSystem in order of increasing period and relative deadline.","category":"page"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"rate_monotonic!\ndeadline_monotonic!","category":"page"},{"location":"tasksystems/#RealTimeScheduling.rate_monotonic!","page":"Task Systems","title":"RealTimeScheduling.rate_monotonic!","text":"rate_monotonic!(T::AbstractRealTimeTaskSystem)\n\nSort the task system T from lowest to highest period.\n\n\n\n\n\n","category":"function"},{"location":"tasksystems/#RealTimeScheduling.deadline_monotonic!","page":"Task Systems","title":"RealTimeScheduling.deadline_monotonic!","text":"deadline_monotonic!(T::AbstractRealTimeTaskSystem)\n\nSort the task system T from lowest to highest period.\n\n\n\n\n\n","category":"function"},{"location":"tasksystems/#Time-Demand-Analysis","page":"Task Systems","title":"Time-Demand Analysis","text":"","category":"section"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"Many schedulability tests make use of time-demand analysis (TDA).  To support this, the common demand bound function (DBF) and request bound function (RBF) are implemented for task systems.","category":"page"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"demand_bound(::AbstractRealTimeTaskSystem, ::Real)\nrequest_bound(::AbstractRealTimeTaskSystem, ::Real)","category":"page"},{"location":"tasksystems/#RealTimeScheduling.demand_bound-Tuple{AbstractRealTimeTaskSystem, Real}","page":"Task Systems","title":"RealTimeScheduling.demand_bound","text":"demand_bound(T::AbstractRealTimeTaskSystem, t)\n\nCompute Baruah's demand bound function (DBF) for task system T.\n\n\n\n\n\n","category":"method"},{"location":"tasksystems/#RealTimeScheduling.request_bound-Tuple{AbstractRealTimeTaskSystem, Real}","page":"Task Systems","title":"RealTimeScheduling.request_bound","text":"request_bound(T::AbstractRealTimeTaskSystem, t)\n\nCompute the request bound function (RBF) for task system T.\n\n\n\n\n\n","category":"method"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"Using the RBF, the package provides an implementation of TDA for uniprocessor fixed-priority task systems.","category":"page"},{"location":"tasksystems/","page":"Task Systems","title":"Task Systems","text":"schedulable_fixed_priority","category":"page"},{"location":"tasksystems/#RealTimeScheduling.schedulable_fixed_priority","page":"Task Systems","title":"RealTimeScheduling.schedulable_fixed_priority","text":"schedulable_fixed_priority(T)\n\nCheck if the AbstractRealTimeTaskSystem T is schedulable by a fixed priority scheduler, with tasks prioritized by index (low to high).\n\nExamples\n\nLehoczky's counterexample to use of traditional TDA when deadlines exceed periods:\n\njulia> ts = TaskSystem([PeriodicTask(70, 70, 26), PeriodicTask(100, 118, 62)]);\n\njulia> schedulable_fixed_priority(ts)\ntrue\n\nShortening the deadline of task 2 makes the system unschedulable:\n\njulia> ts[2] = PeriodicTask(100, 116, 62);\n\njulia> schedulable_fixed_priority(ts)\nfalse\n\n\n\n\n\n","category":"function"},{"location":"#RealTimeScheduling.jl","page":"RealTimeScheduling.jl","title":"RealTimeScheduling.jl","text":"","category":"section"},{"location":"","page":"RealTimeScheduling.jl","title":"RealTimeScheduling.jl","text":"Real-time systems modeling and schedulability analysis","category":"page"},{"location":"","page":"RealTimeScheduling.jl","title":"RealTimeScheduling.jl","text":"This package aims to provide useful tools for writing schedulability studies with Julia.  It provides basic functionality for schedulability testing, response time analysis, schedule simulation, and schedule plotting. It is inspired by SchedCAT by Björn Brandenburg, but is not a direct port since Julia isn't Python. 😉","category":"page"}]
}
