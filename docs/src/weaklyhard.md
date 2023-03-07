# Weakly Hard Systems

RealTimeScheduling provides basic support for weakly hard constraints.

!!! warning
    Support for weakly hard systems is still a work in progress, and the API is
    still very incomplete.  For now, we mainly support the constraints
    themselves, as well as comparisons between them.

Constraints that are logically equivalent compare as equal, even if they are
represented differently.

```@jldoctest
julia> MeetAny(1, 1) == MeetRow(3, 5) == MissRow(0) == HardRealTime()
true

julia> MeetRow(0, 0) == MeetAny(0, 0) == BestEffort()
true

julia> MeetRow(4, 5) == MeetRow(2, 5)
false
```

Testing whether a `BitVector` satisfies a [`WeaklyHardConstraint`](@ref) is
supported.

```@jldoctest
julia> BitVector([0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1]) ⊢ MeetRow(2, 5)
true

julia> BitVector([0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1]) ⊢ MeetRow(2, 5)
false
```


```@docs
WeaklyHardConstraint
MeetAny
MissAny
MeetRow
MissRow
HardRealTime
BestEffort
satisfies
⊢
⊬
```

## Sampling from Weakly Hard Constraints

A weakly hard constraint can be viewed as a sample space of bit strings, with
`0` representing a deadline miss, and `1` representing a deadline hit.  A
finite length must be provided to generate such a string. For now, we only
support uniform sampling from [`MissRow`](@ref) and [`MeetAny`](@ref) constraints.

Unfortunately, the requirement of specifying a string length precludes the
easiest use of the `Random.rand` API.  However, the precomputation required is
non-negligible, so it would be a good idea to first create a sampler anyway.

```@docs
SamplerWeaklyHard
SamplerUniformMissRow
SamplerUniformMeetAny
```
