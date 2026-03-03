using Documenter, DocumenterMarkdown
using ParametricGK

makedocs(
    format = Markdown(),
    modules = [ParametricGK]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
