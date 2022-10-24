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
end

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
end

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
end


Base.show(io::IO, ::MIME"text/latex", c::MeetAny) = print(io, "\\genfrac{(}{)}{0pt}{}{$(c.meet)}{$(c.window)}")
Base.show(io::IO, ::MIME"text/latex", c::MeetRow) = print(io, "\\genfrac{\\langle}{\\rangle}{0pt}{}{$(c.meet)}{$(c.window)}")
Base.show(io::IO, ::MIME"text/latex", c::MissRow) = print(io, "\\overline{\\langle$(c.miss)\\rangle}")
Base.show(io::IO, ::MIME"application/x-latex", c::WeaklyHardConstraint) = show(io, MIME"text/latex", c)

import Base.==
==(c::MeetRow, d::MeetRow) = (2*c.meet > c.window && 2*d.meet > d.window) || (c.meet == d.meet && c.window == d.window)

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
