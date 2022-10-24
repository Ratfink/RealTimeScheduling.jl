"""
    schedulable_fixed_priority(T)

Check if the [`AbstractRealTimeTaskSystem`](@ref) `T` is schedulable by a fixed priority
scheduler, with tasks prioritized by index (low to high).
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
    error("Not implemented: General TDA is not yet available.")
end
