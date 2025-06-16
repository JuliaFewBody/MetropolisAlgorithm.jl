# Please run `include("./dev/docs.jl")` on RELP.

run(`julia --project=docs/ -e 'cd("docs"); using Pkg; Pkg.activate("./"); Pkg.resolve()'`)
run(`julia --project=docs/ -e 'cd("docs"); using Pkg; Pkg.activate("./"); include("make.jl")'`)
