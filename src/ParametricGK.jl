module ParametricGK

export parametricGK

using CUDA
using LinearAlgebra
using SparseArrays
using QuadGK

const newaxis = [CartesianIndex()]

arrayfunction( ::CuArray ) = cu
arrayfunction( ::AbstractArray ) = Array

@doc raw"""
`parametricGK( f, params, as, bs; rtol = 1e-8, atol = 1e-8, nintervals = 100_000 )`

Numerically computes:

$$\int_{a[i]}^{b[i]} f( x[i], y ) dy$$

for `i ∈ 1:length(params)`.

# Arguments
* `f`: The function to integrate
* `params`: A vector of parameters to use as the first argument of the function
* `as`: A vector of lower limits of integration of the 2nd argument of the function
* `bs`: A vector of upper limits of integration of the 2nd argument of the function

"""
function parametricGK( f, params, as, bs;
                       rtol = 1e-8,
                       atol = 1e-8,
                       nintervals = 100_000,
                       arrayf = arrayfunction( params ),
                       )
    sums = arrayf( zeros(length(as)) );

    npoints = size(params,2)
    curr2orig = arrayf( I(npoints) );

    (K15x, K15w, G7w) = kronrod(7)
    K15x = arrayf( [K15x[1:end-1]; 0; -reverse(K15x[1:end-1])] )
    K15w = arrayf( [K15w; reverse(K15w[1:end-1])] )
    G7w = arrayf( [G7w; reverse(G7w[1:end-1])] )

    while size(params,2) > 0
        nsubs = Int(floor(nintervals/length(as)))
        @assert( nsubs > 1 )

        dx = 1/nsubs
        rng = arrayf( collect(0:dx:1) )
        @assert( length(rng) == nsubs + 1 )

        endpoints = (bs .- as) .* rng[newaxis,:] .+ as;
        subas = endpoints[:,1:end-1,newaxis];
        subbs = endpoints[:,2:end,newaxis];

        m = (subbs .- subas)/2;
        K15endpoints = (m .* K15x[newaxis,newaxis,:] .+ (subbs + subas)/2);

        parameters = repeat( params, inner=(1,1,nsubs,15) );

        fx = f( parameters, K15endpoints );

        I0 = m .* sum(fx[:,:,2:2:end] .* G7w[newaxis,newaxis,:], dims=3);
        I1 = m .* sum(fx .* K15w[newaxis,newaxis,:], dims=3);
        err = I0-I1;
        bad = (abs.(err./(I1 .+ curr2orig'*sums)) .>= rtol) .& (abs.(err) .>= atol);
        sums += curr2orig * vec(sum(I1 .* .!bad, dims=2));

        as = subas[bad];
        bs = subbs[bad];
        indices = (bad .* (1:size(params,2)))[bad];
        params = params[:,indices];
        nindices = length(indices)
        if nindices > 0
            transform = sparse( indices, arrayf(collect(1:nindices)), arrayf(ones(nindices)), size(curr2orig,2), nindices );
            curr2orig = curr2orig * transform;
        end
    end
    return sums
end

end
