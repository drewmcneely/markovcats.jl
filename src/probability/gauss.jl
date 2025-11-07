include("./markovcats.jl")

struct Gaussian
	mean::Real
	covariance::Real
end

pressure = Gaussian(23, 15)

struct GaussianKernel
	transform::Real
	noiseMean::Real
	noiseCovariance::Real
end

function push(f::GaussianKernel, p::Gaussian)
	newMean = f.transform * p.mean
	newCov = f.transform * p.covariance * f.transform + f.noiseCovariance
	Gaussian(newMean, newCov)
end
