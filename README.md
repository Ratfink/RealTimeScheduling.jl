# RealTimeScheduling

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Ratfink.github.io/RealTimeScheduling.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Ratfink.github.io/RealTimeScheduling.jl/dev/)
[![Build Status](https://github.com/Ratfink/RealTimeScheduling.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Ratfink/RealTimeScheduling.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Documentation Status](https://github.com/Ratfink/RealTimeScheduling.jl/workflows/Documentation/badge.svg)](https://github.com/Ratfink/RealTimeScheduling.jl/actions?query=workflow%3ADocumentation)

Real-time systems modeling and schedulability analysis

![Logo](docs/src/assets/logo.svg)

This package aims to provide useful tools for writing schedulability studies
with Julia.  It provides basic functionality for schedulability testing,
response time analysis, schedule simulation, and schedule plotting.
It is inspired by [SchedCAT](https://github.com/brandenburg/schedcat) by Björn
Brandenburg, but is not a direct port since Julia isn't Python. 😉

## Note To Researchers

To foster more research collaboration, and enable broader code reuse, you are
encouraged to submit your high-quality research code using this package to the
`RealTimeScheduling.Papers` submodule.  If your code is very broadly
applicable (e.g. new schedulability analysis for GEDF), then we would welcome
it directly to the `RealTimeScheduling` package instead.
