import Random

"""
Abstract parent type of all weakly hard constraints

The concrete subtypes of this, and many of the methods defined on them, are due to Bernat,
Burns, and Llamosí, "Weakly Hard Real-Time Systems," IEEE Trans. Computers, Vol. 50,
No. 4, April 2001.
"""
abstract type WeaklyHardConstraint{T <: Integer} end

"""
    MeetAny{T}(meet::T, window::T)

Weakly hard constraint specifying that a task meets `meet` deadlines in any window of size
`window`.
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
of size `window`.
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


Base.show(io::IO, ::MIME"text/latex", c::MeetAny) = print(io, "\\genfrac{(}{)}{0pt}{}{$(c.meet)}{$(c.window)}")
Base.show(io::IO, ::MIME"text/latex", c::MeetRow) = print(io, "\\genfrac{\\langle}{\\rangle}{0pt}{}{$(c.meet)}{$(c.window)}")
Base.show(io::IO, ::MIME"text/latex", c::MissRow) = print(io, "\\overline{\\langle$(c.miss)\\rangle}")
Base.show(io::IO, ::MIME"application/x-latex", c::WeaklyHardConstraint) = show(io, MIME"text/latex", c)

import Base.==
# Try swapping arguments for unspecified methods
==(c::WeaklyHardConstraint, d::WeaklyHardConstraint) = d == c
# Comparisons of same type
==(c::MeetRow, d::MeetRow) = (2*c.meet > c.window && 2*d.meet > d.window) || (c.meet == d.meet && c.window == d.window)
==(c::MeetAny, d::MeetAny) = (c.meet == 0 && d.meet == 0) || (c.meet == d.meet && c.window == d.window)
==(c::MissRow, d::MissRow) = c.miss == d.miss
# Comparisons for different types
==(c::MeetAny, d::MeetRow) = (c.meet == 0 && d.meet == 0) || (c.meet == c.window && 2*d.meet > d.window)
==(c::MeetAny, d::MissRow) = (c.meet == c.window && d.miss == 0)
==(c::MeetRow, d::MissRow) = (2*c.meet > c.window && d.miss == 0)

import Base.<=
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
