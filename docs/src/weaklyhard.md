# Weakly Hard Systems

RealTimeScheduling provides basic support for weakly hard constraints.

!!! warning
    Support for weakly hard systems is still a work in progress, and the API is
    still very incomplete.  For now, we mainly support the constraints
    themselves, as well as comparisons between them.

```@docs
WeaklyHardConstraint
MeetAny
MissAny
MeetRow
MissRow
```

## Sampling from Weakly Hard Constraints

A weakly hard constraint can be viewed as a sample space of bit strings, with
`0` representing a deadline miss, and `1` representing a deadline hit.  A
finite length must be provided to generate such a string.  For now, we only
support uniform sampling from [`MissRow`](@ref) constraints.

Unfortunately, the requirement of specifying a string length precludes the
easiest use of the `Random.rand` API.  However, the precomputation required is
non-negligible, so it would be a good idea to first create a sampler anyway.

```@docs
SamplerUniformMissRow
```
