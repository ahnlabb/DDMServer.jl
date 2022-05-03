module DDMServer
using DDMFramework
using Logging
using Sockets
using PyCall
using TOML
using ArgParse

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

function __init__()
    mp(analysis, name, keyfun, keytest) = DDMFramework.multipoint(analysis, name, keyfun; keytest)

    py"""
    import operator
    def multipoint(analysis, name, keyfun, keytest=operator.eq):
        return $(mp)(analysis, name, keyfun, keytest)

    def add_plugin(plugin):
        return $(add_plugin)(plugin)
    """
end

function py_file(file)
    m = PyCall.pynamespace(@__MODULE__)
    PyCall.pyeval_(read(file, String), m, m, PyCall.Py_file_input, file)
end

function jl_project(path)
    project_file = joinpath(path, "Project.toml")
    if isfile(project_file)
        project = TOML.parsefile(project_file)
        Base.require(Main, Symbol(project["name"]))
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
                           py_file
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
