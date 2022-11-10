import Random

"""
Abstract parent type of all weakly hard constraints

The concrete subtypes of this, and many of the methods defined on them, are due to Bernat,
Burns, and Llamosí, "Weakly Hard Real-Time Systems," IEEE Trans. Computers, Vol. 50,
No. 4, April 2001.
"""
abstract type WeaklyHardConstraint{T <: Integer} end

Base.length(_::WeaklyHardConstraint) = 1
Base.iterate(c::WeaklyHardConstraint) = (c, nothing)
Base.iterate(_::WeaklyHardConstraint, _) = nothing

"""
    MeetAny{T}(meet::T, window::T)

Weakly hard constraint specifying that a task meets `meet` deadlines in any window of size
`window`.  Must satisfy `0 <= meet <= window`.
"""
struct MeetAny{T} <: WeaklyHardConstraint{T}
    """
    Number of deadlines that must be met within the window
    """
    meet::T
    """
    Window size
    """
    window::T

    function MeetAny{T}(meet, window) where {T<:Integer}
        @boundscheck meet >= 0 || throw(DomainError(meet, "meet must be non-negative"))
        @boundscheck window >= 0 || throw(DomainError(window, "window must be non-negative"))
        @boundscheck meet <= window || throw(DomainError(meet, "meet must be at most window"))
        new(meet, window)
    end
end

MeetAny(meet::T, window::T) where {T<:Integer} = MeetAny{T}(meet, window)

"""
    MeetRow{T}(meet::T, window::T)

Weakly hard constraint specifying that a task meets `meet` deadlines in a row in any window
of size `window`.  Must satisfy `0 <= meet <= window`.
"""
struct MeetRow{T} <: WeaklyHardConstraint{T}
    """
    Number of deadlines that must be met consecutively within the window
    """
    meet::T
    """
    Window size
    """
    window::T

    function MeetRow{T}(meet, window) where {T<:Integer}
        @boundscheck meet >= 0 || throw(DomainError(meet, "meet must be non-negative"))
        @boundscheck window >= 0 || throw(DomainError(window, "window must be non-negative"))
        @boundscheck meet <= window || throw(DomainError(meet, "meet must be at most window"))
        new(meet, window)
    end
end

MeetRow(meet::T, window::T) where {T<:Integer} = MeetRow{T}(meet, window)

"""
    MissAny([T=Int, ]miss, window)

Construct a [`MeetAny{T}`](@ref) constraint that allows at most `miss` deadlines to be
missed in any window of size `window`.

While constraints of this sort are often expressed as a different type in the literature,
they are equivalent to [`MeetAny`](@ref), so using a single type simplifies any code using
weakly hard constraints.
"""
MissAny(T::DataType, miss::Integer, window::Integer) = MeetAny{T}(window - miss, window)
MissAny(miss::Int, window::Int) = MeetAny{Int}(window - miss, window)

"""
    MissRow{T}(miss::T)

Weakly hard constraint specifying that a task misses at most `miss` deadlines in a row.
Must satisfy `0 <= miss`.
"""
struct MissRow{T} <: WeaklyHardConstraint{T}
    """
    Maximum number of deadlines that may be missed consecutively
    """
    miss::T

    function MissRow{T}(miss) where {T<:Integer}
        @boundscheck miss >= 0 || throw(DomainError(miss, "miss must be non-negative"))
        new(miss)
    end
end

MissRow(miss::T) where {T<:Integer} = MissRow{T}(miss)

"""
    HardRealTime{T}()

Weakly hard constraint specifying that no deadlines may be missed.
"""
struct HardRealTime{T} <: WeaklyHardConstraint{T}
end

HardRealTime() = HardRealTime{Int}()

"""
    BestEffort{T}()

Weakly hard constraint specifying that any pattern of deadline misses is acceptable.
"""
struct BestEffort{T} <: WeaklyHardConstraint{T}
end

BestEffort() = BestEffort{Int}()


Base.show(io::IO, ::MIME"text/latex", c::MeetAny) = print(io, "\\genfrac{(}{)}{0pt}{}{$(c.meet)}{$(c.window)}")
Base.show(io::IO, ::MIME"text/latex", c::MeetRow) = print(io, "\\genfrac{\\langle}{\\rangle}{0pt}{}{$(c.meet)}{$(c.window)}")
Base.show(io::IO, ::MIME"text/latex", c::MissRow) = print(io, "\\overline{\\langle$(c.miss)\\rangle}")
Base.show(io::IO, ::MIME"application/x-latex", c::WeaklyHardConstraint) = show(io, MIME"text/latex", c)

import Base.==
# Try swapping arguments for unspecified methods
==(c::WeaklyHardConstraint, d::WeaklyHardConstraint) = d == c
# HardRealTime and BestEffort allow no misses or any pattern, respectively
==(_::HardRealTime, d::WeaklyHardConstraint) = d == MissRow(0)
==(_::BestEffort, d::WeaklyHardConstraint) = d == MeetAny(0,1)
# Comparisons of same type
==(c::MeetRow, d::MeetRow) = (2*c.meet > c.window && 2*d.meet > d.window) || (c.meet == d.meet && c.window == d.window)
==(c::MeetAny, d::MeetAny) = (c.meet == 0 && d.meet == 0) || (c.meet == d.meet && c.window == d.window)
==(c::MissRow, d::MissRow) = c.miss == d.miss
# Comparisons for different types
==(c::MeetAny, d::MeetRow) = (c.meet == 0 && d.meet == 0) || (c.meet == c.window && 2*d.meet > d.window)
==(c::MeetAny, d::MissRow) = (c.meet == c.window && d.miss == 0)
==(c::MeetRow, d::MissRow) = (2*c.meet > c.window && d.miss == 0)

import Base.<=
# HardRealTime is the smallest (hardest) constraint
<=(c::WeaklyHardConstraint, d::HardRealTime) = c == d
<=(_::HardRealTime, _::WeaklyHardConstraint) = true
# BestEffort is the largest (easiest) constraint
<=(_::WeaklyHardConstraint, _::BestEffort) = true
<=(c::BestEffort, d::WeaklyHardConstraint) = c == d
# Due to Bernat, Burns, and Llamosí
<=(c::MeetAny, d::MeetAny) = d.meet <= maximum([floor(d.window/c.window) * c.meet, d.window + ceil(d.window/c.window) * (c.meet - c.window)])
<=(c::MeetRow, d::MeetRow) = (d.window < c.window && d.meet <= c.meet - ceil((c.window - d.window)/2)) || (d.window >= c.window && d.meet <= c.meet)
<=(c::MissRow, d::MissRow) = c.miss <= d.miss

# Due to Vreman, Pates, and Maggio
function <=(c::MeetRow, d::MeetAny)
    p = c.window - c.meet + 1
    d.meet <= c.meet * floor(d.window / p) + maximum([0, c.meet - p + d.window % p])
end
function <=(c::MeetAny, d::MeetRow)
    z = c.window - c.meet
    d.meet <= minimum([floor(d.window / (z + 1)), ceil(c.meet/z)])
end


struct SamplerUniformMissRow <: Random.Sampler{BitVector}
    constraint::MissRow
    H::Int64
    l::Matrix{BigInt}
end

"""
    SamplerUniformMissRow(constraint::MissRow, H::Int64)

Pre-compute data for uniformly sampling `BitVector` objects from a [`MissRow`](@ref)
constraint.  The sampled vectors will have length `H`.

The algorithm used is due to Bernardi, Olivier, and Omer Giménez, "A linear algorithm for
the random sampling from regular languages." Algorithmica 62.1 (2012): 130-145.

# Examples

```julia-repl
julia> sp = SamplerUniformMissRow(MissRow(3), 10);

julia> rand(sp)
10-element BitVector:
1
1
0
1
1
0
1
0
0
1
```
"""
function SamplerUniformMissRow(constraint::MissRow, H::Int64)
    l = zeros(BigInt, constraint.miss+2, H+1)
    l[1:constraint.miss+1, 1] .= 1
    for i = 2:H+1
        for q = axes(l, 1)
            if q == constraint.miss+2
                l[q, i] = 2l[q, i-1]
            else
                l[q, i] = l[q+1, i-1] + l[1, i-1]
            end
        end
    end
    SamplerUniformMissRow(constraint, H, l)
end

function Random.rand!(rng::Random.AbstractRNG, a::BitVector, sp::SamplerUniformMissRow)
    q = 0
    for i = 1:sp.H
        d = sp.l[q + 1, sp.H - i + 2]
        if q == sp.constraint.miss + 1
            prob_one = sp.l[q + 1, sp.H - i + 1]
        else
            prob_one = sp.l[1, sp.H - i + 1]
        end
        a[i] = Random.rand() * d < prob_one
        if q != sp.constraint.miss + 1
            q = (a[i]) ? 0 : q+1
        end
    end
    a
end

function Random.rand(rng::Random.AbstractRNG, sp::SamplerUniformMissRow)
    a = falses(sp.H)
    Random.rand!(rng, a, sp)
end


# Satisfaction
"""
    satisfies(bv::BitVector, c::WeaklyHardConstraint)
    ⊢(bv::BitVector, c::WeaklyHardConstraint)

Check that the `BitVector` `bv` satisfies the weakly hard constraint given by `c`.
"""
satisfies(_::BitVector, c::WeaklyHardConstraint{<:Integer}) = throw(MethodError(satisfies, (typeof(c))))
@doc (@doc satisfies)
⊢(bv::BitVector, c::WeaklyHardConstraint) = satisfies(bv, c)
⊬(bv::BitVector, c::WeaklyHardConstraint) = !satisfies(bv, c)
# First, the trivial methods
satisfies(bv::BitVector, _::HardRealTime) = all(bv)
satisfies(_::BitVector, _::BestEffort) = true
# For MissRow, check that it doesn't contain one miss too many in a row
function satisfies(bv::BitVector, c::MissRow)
    @boundscheck length(bv) >= c.miss || throw(ArgumentError("bv must be at least as long as c.miss"))
    misses = 0
    for b in bv
        if !b
            misses += 1
            misses <= c.miss || return false
        else
            misses = 0
        end
    end
    true
end
# For MeetAny, check that all windows contain enough hits
function satisfies(bv::BitVector, c::MeetAny)
    @boundscheck length(bv) >= c.window || throw(ArgumentError("bv must be at least as long as c.window"))
    # Initialize our counter
    meets = count(bv[1:c.window])
    meets >= c.meet || return false
    # Check that there are at least c.meet deadlines met in each c.window
    for i in 1:(length(bv) - c.window)
        meets += bv[i + c.window] - bv[i]
        meets >= c.meet || return false
    end
    true
end
# For MeetRow, check that all windows contain a run of hits
function satisfies(bv::BitVector, c::MeetRow)
    @boundscheck length(bv) >= c.window || throw(ArgumentError("bv must be at least as long as c.window"))
    # Initialize
    meets = 0
    safe = c.window - 1
    # Check that there is a row of at least c.meet deadlines met in each c.window
    for i in eachindex(bv)
        if bv[i]
            meets += 1
            if meets >= c.meet
                safe = i + c.window - c.meet
                safe < length(bv) || return true
            end
        else
            meets = 0
            i <= safe - c.meet + 1 || return false
        end
    end
    return true
end
