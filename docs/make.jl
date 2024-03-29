using Documenter
using RealTimeScheduling

DocMeta.setdocmeta!(RealTimeScheduling, :DocTestSetup, :(using RealTimeScheduling); recursive=true)

makedocs(
    sitename = "RealTimeScheduling",
    format = Documenter.HTML(),
    modules = [RealTimeScheduling],
    pages = [
        "index.md",
        "tasks.md",
        "tasksystems.md",
        "schedules.md",
        "responsetime.md",
        "weaklyhard.md",
        "Papers" => [
            "papers/index.md",
            "papers/job_class_level_scheduling.md",
        ]
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/Ratfink/RealTimeScheduling.jl.git"
)
