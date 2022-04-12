using DDMServer
using Documenter

DocMeta.setdocmeta!(DDMServer, :DocTestSetup, :(using DDMServer); recursive=true)

makedocs(;
    modules=[DDMServer],
    authors="Johannes Ahnlide <johannes@voxel.se> and contributors",
    repo="https://github.com/ahnlabb/DDMServer.jl/blob/{commit}{path}#{line}",
    sitename="DDMServer.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ahnlabb.github.io/DDMServer.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ahnlabb/DDMServer.jl",
    devbranch="main",
)
