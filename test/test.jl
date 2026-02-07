using ParametricGK
using Random
using QuadGK

bound( params, ϵ ) = let λ = params[2:end],
    k = length(λ)/2
    ((π*length(λ)/2*prod(abs.(λ[λ .!= 0]).^(1/2)))/ϵ)^(1/k)
end

function parametric_integrand( params::AbstractArray{T}, u::AbstractArray{T} ) where T
    sizep = size(params)
    sizeu = size(u)
    @assert( sizep[2:end] == sizeu )
    λ₃ = selectdim( params, 1, 2:sizep[1] )
    u₃ = reshape( u, (1, sizeu...) )
    x₃ = selectdim( params, 1, 1:1 )
    θ = (sum(atan.(u₃ .* λ₃), dims=1) .- u₃ .* x₃)./2
    ρ = prod( 1 .+ u₃.^2 .* λ₃.^2, dims=1 ).^(1/4)
    return selectdim( (sin.(θ)./(u₃.*ρ)), 1, 1 )
end

Random.seed!(1)
nparams = 11
npoints = 1_000
params = randn( nparams, npoints );
as = fill( eps(Float64), npoints );
ϵ = 1e-11
bs = bound.( eachcol(params[2:end,:]), ϵ )

@time r1 = parametricGK( parametric_integrand, copy(params), copy(as), copy(bs) );

newaxis = [CartesianIndex()]
f( params ) = u -> parametric_integrand( params[:,newaxis], [u] )[1]

@time r0 = [quadgk(f( params[:,i] ), as[i], bs[i], rtol=1e-13 )[1] for i in 1:npoints];

error = maximum( abs.( 1 .- r1 ./ r0 ) )
@assert( error < sqrt(ϵ) )
