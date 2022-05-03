#!/bin/sh

julia --project=. -e 'using PackageCompiler; create_app(".", "compiled"; force=true, include_lazy_artifacts=true)'
