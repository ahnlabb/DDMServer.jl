#!/bin/sh

julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.add("PackageCompiler")'
julia --project=. -e 'using PackageCompiler; create_app(".", "compiled"; force=true, include_lazy_artifacts=true)'
