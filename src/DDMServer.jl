module DDMServer
using Logging
import Pkg

if !isfile(joinpath(first(DEPOT_PATH), "prefs", "PyCall"))
    Pkg.build("PyCall")
end

using DDMFramework
using Sockets
using TOML
using ArgParse
using DataFrames

py_file_loader = try
    include("python_plugins.jl")
    py_file
catch ex
    @warn "failed to initialize Python plugins" exception=(ex,catch_backtrace())
    function py_fail_loader(path)
        @warn "failed to load Python plugin at $path, Python plugins not initialized"
    end
end

function get_args()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--port"
            help = "specify listening port"
            arg_type = Int
            default = 4443
    end
    parse_args(s)
end

function jl_project(path)
    project_file = joinpath(path, "Project.toml")
    @info "Loading Julia project at $project_file"
    if isfile(project_file)
        project = TOML.parsefile(project_file)
        try
            Pkg.add(Pkg.PackageSpec(; path=path))
            Base.require(Main, Symbol(project["name"]))
        catch e
            Base.showerror(stderr, e, catch_backtrace())
            @warn "failed to load Julia plugin at $path"
        end
    end
end

function tryloaders(path, loaders...)
    for l in loaders
        res = l(path)
        if !isnothing(res)
            return res
        end
    end
end


function julia_main()::Cint
    args = get_args()
    plugins_dir = "plugins"

    if isdir(plugins_dir)
        for p in readdir(plugins_dir)
            if !startswith(".", p)
                tryloaders(
                           joinpath(plugins_dir, p),
                           jl_project,
                           py_file_loader
                          )
            end
        end
    else
        @warn "plugin directory not found"
    end

    host = ip"127.0.0.1"
    port = args["port"]
    @info "starting server"
    server, task = DDMFramework.serve_ddm_application(;host, port)
    @info "server started"
    try
        wait(task)
    catch e
        @async Base.throwto(task, InterruptException())
        close(server)
        rethrow(e)
    end
    return 0
end

end
