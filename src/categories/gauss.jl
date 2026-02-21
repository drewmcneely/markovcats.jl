using LinearAlgebra

struct GaussStateSpace
    dimension::Int
end

struct GaussianKernel
    map::Matrix{Float64}
    mean::Vector{Float64}
    covariance::Matrix{Float64}
    function GaussianKernel(map, mean, covariance)
        (codom, dom) = size(map)
        @assert length(mean) == codom
        @assert size(covariance) == (codom, codom)
        new(map, mean, covariance)
    end
end

𝓝(μ,Σ) = GaussianKernel( Matrix{Float64}(undef, length(μ), 0), μ, Σ)
Gaussian = 𝓝

state(v) = 𝓝(v, zeros(Matrix{Float64}, length(v), length(v)))
affine(A, b) = GaussianKernel(A, b, zeros(Matrix{Float64}, length(b), length(b)))
linear(A) = affine(A, zeros(Vector{Float64}, size(A, 1)))

# vvv ADDED BY CLAUDE vvv
hom_to_obs(k::GaussianKernel) = (GaussStateSpace(size(k.map, 2)), GaussStateSpace(size(k.map, 1)))
# ^^^ ADDED BY CLAUDE ^^^

@instance ThMarkovCategory{GaussStateSpace, GaussianKernel} begin

    dom(f) = size(f.map, 2)
    codom(f) = size(f.map, 1)

    id(X) = linear(Matrix{Float64}(LinearAlgebra.I, X.dimension, X.dimension))

    function compose(f, g)
        F, G = f.map, g.map
        μf, μg = f.mean, g.mean
        Σf, Σg = f.covariance, g.covariance
        M = G * F
        μ = G * μf + μg
        Σ = G * Σf * G' + Σg
        GaussianKernel(M, μ, Σ)
    end

    munit() = GaussStateSpace(0)

    otimes(X::GaussStateSpace, Y::GaussStateSpace) = GaussStateSpace(X.dimension + Y.dimension)

    function otimes(f::GaussianKernel, g::GaussianKernel)
        F, G = f.map, g.map
        μf, μg = f.mean, g.mean
        Σf, Σg = f.covariance, g.covariance
        M = [F zeros(size(F,1), size(G,2)); zeros(size(G,1), size(F,2)) G]
        μ = vcat(μf, μg)
        Σ = [ΣF zeros(size(ΣF,1), size(ΣG,2)); zeros(size(ΣG,1), size(ΣF,2)) ΣG]
        GaussianKernel(M, μ, Σ)
    end

    function braid(X, Y)
        IX = Matrix{Float64}(LinearAlgebra.I, X.dimension, X.dimension)
        IY = Matrix{Float64}(LinearAlgebra.I, Y.dimension, Y.dimension)
        Z1 = zeros(Matrix{Float64}, X.dimension, Y.dimension)
        Z2 = Z1'
        linear([Z1 IX; IY Z2])
    end

    function mcopy(X)
        n = X.dimension
        IX = Matrix{Float64}(LinearAlgebra.I, n, n)
        linear(vcat(IX, IX))
    end

    delete(X) = linear( Matrix{Float64}(undef, 0, X.dimension))

end
