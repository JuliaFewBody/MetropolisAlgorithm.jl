import Pkg;
Pkg.activate("$(@__DIR__)/..")
using MetropolisAlgorithm
using Printf
using Random

Random.seed!(123)

ψ(r) = r[1] * r[2] * exp(- r[1]^2 - r[2]^2 - r[3]^2)
p(r) = abs2(ψ(r))
R = [zeros(3) for i ∈ 1:5000]
metropolis!(r -> abs2(ψ(r)), R)
metropolis!(r -> abs2(ψ(r)), R)
metropolis!(r -> abs2(ψ(r)), R)
metropolis!(r -> abs2(ψ(r)), R)
metropolis!(r -> abs2(ψ(r)), R)

svg = """
<?xml version="1.0" encoding="UTF-8"?>
<svg
  version="1.1"
  xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  width="325pt"
  height="300pt"
  viewBox="0 0 325 300"
>

  <!-- Circle -->
"""

for r ∈ R
  x = @sprintf("%.3f", 100 * r[1] + 162.5)
  y = @sprintf("%.3f", 100 * r[2] + 150.0)
  if r[1] < 0 && r[2] > 0
    c = "#CB3C33"
  elseif r[1] > 0 && r[2] < 0
    c = "#4063D8"
  elseif r[1] < 0 && r[2] < 0
    c = "#389826"
  elseif r[1] > 0 && r[2] > 0
    c = "#9558B2"
  end
  global svg = string(svg, "<circle cx=\"$(x)\" cy=\"$(y)\" r=\"3\" fill=\"$(c)\"/>")
end

svg = string(svg, "</svg>")

path = "./logo.svg"
mkpath(dirname(path))
file = open(path, "w")
Base.write(file, svg)
close(file)
