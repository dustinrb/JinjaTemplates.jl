module JinjaTemplates

export LazyTemplateLoader, get_template_name, render

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
end

""" Returns a jinja template. Onload loads the tempalte once requested """
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

""" Takes a variable and converts its type into a string fit for the filesystem """
function get_template_name(item)
    t = string(typeof(item))
    return replace(t, r"[^\w\.]", s"_")
end

""" Renders given kwargs into the specified tempalte """
function render(loader::LazyTemplateLoader, template::AbstractString; kwargs...)
    template = loader[template]
    return template[:render](; kwargs...)
end

render(loader::LazyTemplateLoader, obj, extension; kwargs...) = render(loader, "$get_template_name(obj).$extension"; kwargs...)

end # module
