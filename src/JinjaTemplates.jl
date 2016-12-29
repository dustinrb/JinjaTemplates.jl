module JinjaTemplates

export LazyTemplateLoader, get_template_name, render, get_searchpaths, add_searchpath!

using PyCall
@pyimport jinja2

""" Object to store in memory PyObjects representing Jinja templates """
type LazyTemplateLoader
    jinjaenv
    templates

    function LazyTemplateLoader(paths::Array; kwargs...)
        env = jinja2.Environment(;
            loader=jinja2.FileSystemLoader(paths),
            kwargs...
        )
        return new(env, Dict())
    end
    LazyTemplateLoader(path::AbstractString; kwargs...) = LazyTemplateLoader([path]; kwargs...)
end

""" Returns a jinja template. Onload loads the template once requested """
function Base.getindex(loader::LazyTemplateLoader, key)
    try
        return loader.templates[key]
    catch x
        if isa(x, KeyError)
            loader.templates[key] = loader.jinjaenv[:get_template](key)
            return loader.templates[key]
        else
            throw(x)
        end
    end
end

"""
Returns an array of the curret template sources
"""
get_searchpaths(loader::LazyTemplateLoader) = loader.jinjaenv[:loader][:searchpath]

"""
Insert location into search path

`at` can be :start, :end, :index
index is a 1 based index representing the position
"""
function add_searchpath!(loader::LazyTemplateLoader, path::AbstractString; at=:start, index=1)
    searchpath = loader.jinjaenv[:loader]["searchpath"]
    if is(at, :start)
        searchpath[:insert](0, path)
    elseif is(at, :end)
        searchpath[:append](path)
    elseif is(at, :index)
        searchpath[:insert](index-1, path)
    end

    # Clear cache
    loader.templates=Dict()
    return loader
end

"""
Takes a variable and converts its type into a string fit for the filesystem
"""
function get_template_name(item)
    t = string(typeof(item))
    return replace(t, r"[^\w\.]", s"_")
end

""" Renders given kwargs into the specified template """
function render(loader::LazyTemplateLoader, template::AbstractString; kwargs...)
    template = loader[template]
    return template[:render](; kwargs...)
end

render(loader::LazyTemplateLoader, obj, extension; kwargs...) = render(loader, "$get_template_name(obj).$extension"; kwargs...)

end # module
