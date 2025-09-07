```@meta
CurrentModule = MetropolisAlgorithm
```

# MetropolisAlgorithm.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaFewBody.github.io/MetropolisAlgorithm.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaFewBody.github.io/MetropolisAlgorithm.jl/dev/)
[![Build Status](https://github.com/JuliaFewBody/MetropolisAlgorithm.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaFewBody/MetropolisAlgorithm.jl/actions/workflows/CI.yml?query=branch%3Amain)

Minimal implementation of the Metropolis algorithm.

## Install

Run the following code to install this package.

```julia
import Pkg; Pkg.add(url="https://github.com/JuliaFewBody/MetropolisAlgorithm.jl.git")
```

## Usage

Run the following code before each use.

```@example
using MetropolisAlgorithm
```

Here is a minimal working example for 1-walker x 10000-steps, 2-dimensional Metropolis-walk using `metropolis()`. This function returns the trajectory as a vector of vectors (points), where the first argument is the (normalized or unnormalized) distribution function, and the second argument is the initial value vector. Optional arguments can be used to set the number of steps, element type (Float32, Float64, etc.), and the maximum step size. 

```@example
using MetropolisAlgorithm
p(r) = exp(- r' * r)  # distribution function
r₀ = [0.0, 0.0]       # initial position
R = metropolis(p, r₀) # 1-walker x 10000-steps
```

In the variational Monte Carlo method (VMC), sampling is performed simultaneously with multiple walkers (rather than just one walker). Here is an example of 10000-walkers x 5-steps, 2-dimensional Metropolis-walk using `metropolis!()`. This function overwrites its second argument without memory allocation, where the first argument is the (normalized or unnormalized) distribution function, and the second argument is the vector of the initial value vectors. Use the For statement to repeat as many times as you like. Remove the first several steps by yourself to ensure equilibrium.

```@example
using MetropolisAlgorithm
p(x) = exp(- x' * x)              # distribution function
R = [[0.0, 0.0] for i in 1:10000] # initial position(s)
metropolis!(p, R)                 # the 1st step of 10000-walkers
metropolis!(p, R)                 # the 2nd step of 10000-walkers
metropolis!(p, R)                 # the 3rd step of 10000-walkers
metropolis!(p, R)                 # the 4th step of 10000-walkers
metropolis!(p, R)                 # the 5th step of 10000-walkers
```

Please see [Examples](./examples.md) and [API reference](./API.md) for more information.

## Citation

Please cite this package, the original paper by Metropolis et al. and the textbook by Thijssen:
- [N. Metropolis, A. W. Rosenbluth, M. N. Rosenbluth, A. H. Teller, E. Teller, _J. Chem. Phys._, **21**, 1087–1092 (1953)](https://doi.org/10.1063/1.1699114),
- [J. M. Thijssen, _Computational Physics 2nd edition_, (Cambridge University Press, 2007)](https://doi.org/10.1017/CBO9781139171397).

```@example
file = open("../../CITATION.bib", "r") # hide
text = Base.read(file, String) # hide
close(file) # hide
println(text) # hide
```
