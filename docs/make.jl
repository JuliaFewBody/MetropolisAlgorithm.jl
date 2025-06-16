using MetropolisAlgorithm
using Documenter

DocMeta.setdocmeta!(MetropolisAlgorithm, :DocTestSetup, :(using MetropolisAlgorithm); recursive = true)

makedocs(;
  modules = [MetropolisAlgorithm],
  authors = "Shuhei Ohno",
  sitename = "MetropolisAlgorithm.jl",
  format = Documenter.HTML(;
    canonical = "https://ohno.github.io/MetropolisAlgorithm.jl",
    edit_link = "main",
    assets = String[
      "./assets/logo.ico",
    ],
  ),
  pages = [
    "Home"          => "index.md",
    "Examples"      => "examples.md",
    "API reference" => "API.md",
  ],
)

deploydocs(;
  repo = "github.com/ohno/MetropolisAlgorithm.jl",
  devbranch = "main",
)
