using Distributions
using MetropolisAlgorithm
using Printf
using Test

@testset verbose=true "MetropolisAlgorithm.jl" begin
  for d ∈ [
    Normal(0, 1),
    SymTriangularDist(0, 1),
    Uniform(0, 1),
    Gamma(7.5, 1),
    TriangularDist(0, 1, 0.2),
    Semicircle(1),
  ]

    # properties
    μ = Distributions.mean(d)
    σ = Distributions.std(d)

    # sampling
    R = metropolis(x -> Distributions.pdf(d, x[1]), [1.0], n_steps = 100000, d = σ)

    # test
    @testset verbose=true "$d" begin
      @show d
      println("------------------------------------")
      println("   x           Exact      Metropolis")
      println("------------------------------------")
      Δx = 0.1
      for x ∈ (-5 * σ + μ):Δx:(5 * σ + μ)
        numerical  = MetropolisAlgorithm.pdf([x], [Δx], R)
        analytical = Distributions.pdf(d, x[1])
        acceptance = isapprox(analytical, numerical, rtol = 1e-1, atol = 1e-1)
        @printf("%+.1f    %+.9f    %+.9f  %s\n", x, numerical, analytical, acceptance ? "✔" : "✗")
        @test acceptance
      end
      println("------------------------------------")
    end
    println()
  end
end
