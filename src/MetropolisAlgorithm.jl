module MetropolisAlgorithm

# export
export metropolis, metropolis!, count, pdf

# import
using Random
Random.seed!(123)

# one-step x many-walkers
function metropolis!(f::Function, R::Vector{<:Vector}; type = typeof(first(first(R))), d::Real = one(type))
  # initialize
  half = type(1//2)
  n_dim = length(first(R))
  # Metropolis-walk
  for i ∈ keys(R)
    # shift
    Δr = d * (rand(type, n_dim) .- half) # [-d/2,d/2)ⁿ
    r_old = R[i]
    f_old = f(r_old)
    r_new = r_old .+ Δr
    f_new = f(r_new)
    # accept
    p = min(1, f_new / f_old)
    if rand() < p
      R[i] = r_new
    end
  end
  return
end

# many-steps x one-walker
function metropolis!(f::Function, R::Vector{<:Vector}, r_ini::Vector{<:Real}; type = typeof(first(r_ini)), d::Real = one(type))
  # initialize
  half = type(1//2)
  n_dim = length(r_ini)
  n_steps = length(R)
  r_old = r_ini
  f_old = f(r_ini)
  # Metropolis-walk
  for i ∈ 2:n_steps
    # shift
    Δr = d * (rand(type, n_dim) .- half) # [-d/2,d/2)ⁿ
    r_new = r_old + Δr
    f_new = f(r_new)
    # accept
    p = min(1, f_new / f_old)
    if rand() < p
      r_old = r_new
      f_old = f_new
    end
    # save
    R[i] = r_old
  end
  return
end

# many-steps x one-walker with memory allocation
function metropolis(f::Function, r_ini::Vector{<:Real}; n_steps::Int = 10^4, type = typeof(first(r_ini)), d::Real = one(type))
  # memory allocation
  R = fill(typeof(r_ini)(undef, size(r_ini)), n_steps)
  R[begin] = r_ini
  # Metropolis sampling
  metropolis!(f, R, r_ini; d = d)
  # return
  return R
end

struct bin
  min::Vector{<:Real}
  max::Vector{<:Real}
  width::Vector{<:Real}
  number::Vector{<:Int}
  center::Vector{Vector{<:Real}}
  corner::Vector{Vector{<:Real}}
  counter::Array
  function bin(A::Vector{<:Vector}; number = fill(10, length(first(A)))) # A = [[0,2], [2,2], [2,4]], number = [3,3]
    min = [minimum(a[i] for a ∈ A) for i ∈ keys(first(A))] # [0,2]
    max = [maximum(a[i] for a ∈ A) for i ∈ keys(first(A))] # [2,4]
    width = [(max[n] - min[n]) / (number[n]-1) for n ∈ keys(number)] # [1,1]
    center = [[((i)*max[n] + (number[n]-1-i)*min[n]) / (number[n]-1) for i ∈ 0:(number[n] - 1)] for n ∈ keys(number)] # [[0,1,2], [2,3,4]]
    corner = [[((i-1//2)*max[n] + (number[n]-1-i+1//2)*min[n]) / (number[n]-1) for i ∈ 0:number[n]] for n ∈ keys(number)] # [[-0.5,0.5,1.5,2.5], [1.5,2.5,3.5,4.5]]
    counter = zeros(Int64, number...)
    for k ∈ Iterators.product([1:n for n ∈ number]...)
      a₋ = [corner[i][k[i]] for i ∈ keys(k)]
      a₊ = [corner[i][k[i] + 1] for i ∈ keys(k)]
      c = count(a -> prod(a₋ .≤ a .< a₊), A)
      counter[k...] = c
    end
    new(min, max, width, number, center, corner, counter)
  end
end

function Base.count(center::Vector, width::Vector, A::Vector{<:Vector})
  a₋ = center .- width / 2
  a₊ = center .+ width / 2
  return count(a -> prod(a₋ .≤ a .< a₊), A)
end

function pdf(center::Vector, width::Vector, A::Vector{<:Vector})
  return count(center, width, A) / length(A) / prod(width)
end

# docstrings

@doc raw"""
    metropolis!(f::Function, R::Vector{<:Vector}; type=typeof(first(first(R))), d::Real=one(type))

This function calculates **one-step of many-walkers** and overwrites the second argument `R`. Each child vector in `R` is a point of the walker (not a trajectory).

# Arguments
- `f::Function`: Distribution function. It does not need to be normalized.
- `R::Vector{<:Vector}`: Vector of vectors (points). Each child vector is a point of the walker.
- `type::Type=typeof(first(first(R)))`: Type of trajectory points. e.g., Float32, Float64, etc..
- `d::Real=one(type)`: Maximum step size. 
""" metropolis!(f::Function, R::Vector{<:Vector})

@doc raw"""
    metropolis!(f::Function, R::Vector{<:Vector}, r_ini::Vector{<:Real}; type=typeof(first(r_ini)), d::Real=one(type))

This function calculates **many-steps of one-walker** and overwrites the second argument `R`. Each child vector in `R` is a point of the trajectory.

# Arguments
- `f::Function`: Distribution function. It does not need to be normalized.
- `r_ini::Vector{<:Real}`: Initial value vector. Even in the one-dimensional case, the initial value must be defined as a vector. Each child vector (point) has the same size as `r_ini`.
- `R::Vector{<:Vector}`: Vector of vectors (points). Each child vector is a point of the walker. The first element of `R` is same as `r_ini`.
- `n_steps::Int=10^5`: Number of steps. It is same as the length of the output parent vector.
- `type::Type=typeof(first(r_ini))`: Type of trajectory points. e.g., Float32, Float64, etc..
- `d::Real=one(type)`: Maximum step size. Default value is 1.
""" metropolis!(f::Function, R::Vector{<:Vector}, r_ini::Vector{<:Real})

@doc raw"""
    metropolis(f::Function, r_ini::Vector{<:Real}; n_steps::Int=10^5, type=typeof(first(r_ini)), d::Real=one(type))

This function calculates **many-steps of one-walker** using `metropolis!(f, R, r_ini)` and returns the trajectory `R` as a vector of vectors (points) with memory allocation.
""" metropolis(f::Function, r_ini::Vector{<:Real})

@doc raw"""
    bin(A::Vector{<:Vector}; number = fill(10,length(first(A))))

This function creates a data for multidimensional histogram for testing.

# Examples
```julia
using Random
A = [randn(2) for i in 1:10000]

using MetropolisAlgorithm
b = MetropolisAlgorithm.bin(A, number=[10,10])

using CairoMakie
X = b.center[1]
Y = b.center[2]
Z = b.counter
heatmap(X, Y, Z)
```
""" bin(A::Vector{<:Vector})

@doc raw"""
    count(center::Vector, width::Vector, A::Vector{<:Vector})

This function counts the number of points in `A` that fall within the bin defined by `center` and `width`.

# Arguments
- `center::Vector`: Center of the bin. A vector of coordinates.
- `width::Vector`: Width of the bin (rectangle, hypercube). A vector of coordinates.
- `A::Vector{<:Vector}`: Vector of vectors (points). Each child vector is a point.

# Examples
```julia-repl
julia> count([0], [2], [randn(1) for i in 1:100000]) / 100 # ≈ 68.3% ()
68.395

julia> count([0], [0.1], [randn(1) for i in 1:100000]) / 100000 / 0.1
0.3988

julia> exp(0) / sqrt(2*π)
0.3989422804014327
```
""" count(center::Vector, width::Vector, A::Vector{<:Vector})

@doc raw"""
    pdf(center::Vector, width::Vector, A::Vector{<:Vector})

This function approximates the probability density function (PDF) with normalizing `count(center, width, A)`. For the Metropolis algorithm, this function is not needed since the distribution function is known. It is used for testing the algorithm.

# Arguments
- `center::Vector`: Center of the bin. A vector of coordinates.
- `width::Vector`: Width of the bin. A vector of coordinates.
- `A::Vector{<:Vector}`: Vector of vectors (points). Each child vector is a point.

# Examples
```julia-repl
julia> pdf([0.0], [0.2], [randn(1) for i in 1:1000000])
0.39926999999999996

julia> exp(0) / sqrt(2*π)
0.3989422804014327

julia> pdf([0.0, 0.0], [0.2, 0.2], [randn(2) for i in 1:1000000])
0.15389999999999998
s
julia> exp(0) / sqrt(2*π)^2
0.15915494309189537

julia> pdf([0.0, 0.0, 0.0], [0.2, 0.2, 0.2], [randn(3) for i in 1:1000000])
0.06162499999999998

julia> exp(0) / sqrt(2*π)^3
0.06349363593424098
```
""" pdf(center::Vector, width::Vector, A::Vector{<:Vector})

end
