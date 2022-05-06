using PyCall
import Pandas

function py_file(path)
    try
        m = PyCall.pynamespace(@__MODULE__)
        PyCall.pyeval_(read(path, String), m, m, PyCall.Py_file_input, path)
    catch ex
        @warn "failed to load Python plugin at $path" exception=(ex,catch_backtrace())
    end
end


function __init__()
    pyimport_conda("skimage", "scikit-image")
    _python_multipoint(analysis, name, keyfun, keytest) = DDMFramework.multipoint(DataFrame ∘ analysis, name, keyfun; keytest)

    py"""
    import operator

    def multipoint(analysis, name, keyfun, keytest=operator.eq):
        return $(_python_multipoint)(analysis, name, keyfun, keytest)

    def add_plugin(plugin):
        return $(add_plugin)(plugin)
    """
end
