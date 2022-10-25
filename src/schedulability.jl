"""
    schedulable_fixed_priority(T)

Check if the [`AbstractRealTimeTaskSystem`](@ref) `T` is schedulable by a fixed priority
scheduler, with tasks prioritized by index (low to high).

# Examples

Lehoczky's counterexample to use of traditional TDA when deadlines exceed periods:

```jldoctest lehoczky
julia> ts = TaskSystem([PeriodicTask(70, 70, 26), PeriodicTask(100, 118, 62)]);

julia> schedulable_fixed_priority(ts)
true
```

Shortening the deadline of task 2 makes the system unschedulable:

```jldoctest lehoczky
julia> ts[2] = PeriodicTask(100, 116, 62);

julia> schedulable_fixed_priority(ts)
false
```
"""
function schedulable_fixed_priority(T::AbstractRealTimeTaskSystem)
    # First run a utilization test, due to Liu and Layland
    utilization(T) < _u_rm(length(T)) && return true
    utilization(T) > 1 && return false

    # If utilization test fails, fall back to time-demand analysis (TDA)
    if constrained_deadline(T)
        # In the constrained deadline case, Lehoczky, Sha, and Ding's TDA method is
        # necessary and sufficient for sporadic or abstract periodic task systems.
        return _tda_lsd(T)
    else
        # If some tasks' deadlines exceed their periods, fall back to general TDA
        return _general_tda(T)
    end
end

_u_rm(n::Integer) = n * (2^(1/n) - 1)

function _fixed_point(f::Function, init, bound)
    val = init
    while val < bound
        newval = f(val)
        if newval == val
            return val
        end
        val = newval
    end
    return val
end

function _tda_lsd(T::AbstractRealTimeTaskSystem)
    for i in axes(T, 1)
        hep = T[begin:i]
        fp = _fixed_point(t -> request_bound(hep, t), sum(cost, hep), deadline(T[i]))
        if fp > deadline(T[i])
            return false
        end
    end
    return true
end

function _general_tda(T::AbstractRealTimeTaskSystem)
    for i in axes(T, 1)
        # Compute the length of the busy interval for task i
        hep = T[begin:i]
        H = prod(period, hep)
        busy_interval = _fixed_point(t -> request_bound(hep, t), sum(cost, hep), H)
        # If it's greater than the hyperperiod of all hep tasks, unbounded deadline misses
        if busy_interval > H
            return false
        end
        # Stop here for task 1
        i > 1 || continue
        # Check the response time of each job in the busy interval
        jobs = ceil(busy_interval / period(T[i]))
        hp = T[begin:i-1]
        for job in 1:jobs
            abs_deadline = period(T[i])*(job-1) + deadline(T[i])
            fp = _fixed_point(t -> request_bound(hp, t) + cost(T[i])*job, sum(cost, hp), abs_deadline)
            if fp > abs_deadline
                return false
            end
        end
    end
    return true
end
