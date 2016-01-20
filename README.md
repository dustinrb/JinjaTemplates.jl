# JinjaTemplates

[![Build Status](https://travis-ci.org/dustinrb/JinjaTemplates.jl.svg?branch=master)](https://travis-ci.org/dustinrb/JinjaTemplates.jl)

JinjaTemplates is a light wrapper around the Jinja2 templating library for Python.

## Installation

First install Jinja2 to your python environment.

```sh
pip install Jinja2
```

Then, in the Julia REPL, install JinjaTemplates

```julia
Pkg.add("JinjaTemplates")
```

## Usage

### Jinja2

For more information on how to write Jinja2 templates, please see the official [documentation for template designers](http://jinja.pocoo.org/docs/dev/templates/).

### LazyTemplateLoader(paths; kwargs...)

`paths` is an Array of paths pointing to the directories where you store your templates. `kwargs` are any [options](http://jinja.pocoo.org/docs/dev/api/#jinja2.Environment) to customize the Jinja2 Environment. The only exception is the loader, which uses a [FileSystemLoader](http://jinja.pocoo.org/docs/dev/api/#jinja2.FileSystemLoader) with itsn `searchpath` set to the directories specified in `path`

### render(env, template; kwargs...)

`render` renders the desired template and returns the result as a String. `env` is a LazyTempalteLoader. Template is the template name/path relative to the paths specified when `env` was created. `kwargs` are any you wish to pass to the template.

## Example

Say we have a template `index.html` in `/home/username/webdev/templates` and we want to render it.

```html
<!-- index.html -->
<!DOCUMENT html>
<html>
<head>
    <title>Title<title>
</head>
<body>
    <h1>This is my content!</h1>
    {{content}}
</body>
</html>
```

```julia
using JinjaTemplates

# Set two paths for Jinja2 to look in
env = LazyTemplateLoader(
    ["/home/username/templates",
    "/home/username/webdev/templates"]
)

# Render it!
# Because there are two paths specified, Jinja will search first in
#    /home/username/templates and then /home/username/webdev/templates
#    index.html is not found.
render(env, "index.html"; content="This is content!") # Returns:
# <!-- index.html -->
# <!DOCUMENT html>
# <html>
# <head>
#     <title>Title<title>
# </head>
# <body>
#     <h1>This is my content!</h1>
#     This is content
# </body>
# </html>
```