# Response Time Analysis

RealTimeScheduling supports calculating response time and tardiness bounds for
task systems under global earliest deadline first (GEDF) scheduling.  Multiple
algorithms are supported, as shown below.

```@jldoctest responsetime
julia> T = TaskSystem([PeriodicImplicitTask(3, 2), PeriodicImplicitTask(3, 2), PeriodicImplicitTask(6, 4)]);

julia> tardiness_gedf(T, 2, GEDFDeviAnderson)
3-element Vector{Float64}:
 3.0
 3.0
 5.0

julia> tardiness_gedf(T, 2, GEDFCompliantVector)
3-element Vector{Float64}:
 3.0
 3.0
 4.0
```

Intuitively, increasing the number of processors results in lower response time
bounds for the same task system.

```@jldoctest responsetime
julia> tardiness_gedf(T, 3, GEDFDeviAnderson)
3-element Vector{Float64}:
 2.6666666666666665
 2.6666666666666665
 4.666666666666667

julia> tardiness_gedf(T, 3, GEDFCompliantVector)
3-element Vector{Float64}:
 2.6666666666666665
 2.6666666666666665
 4.0
```

```@docs
tardiness_gedf
response_time_gedf
GEDFDeviAnderson
GEDFCompliantVector
```
