<a id='ParametricGK.parametricGK-NTuple{4, Any}' href='#ParametricGK.parametricGK-NTuple{4, Any}'>#</a>
**`ParametricGK.parametricGK`** &mdash; *Method*.



`parametricGK( f, params, as, bs; rtol = 1e-8, atol = 1e-8, nintervals = 100_000 )`

Numerically computes a $\int_{a[i]}^{b[i]} f( x[i], y ) dy$ for `i ∈ 1:length(params)`.

**Arguments**

  * `f`: The function to integrate
  * `params`: A vector of parameters to use as the first argument of the function
  * `as`: A vector of lower limits of integration of the 2nd argument of the function
  * `bs`: A vector of upper limits of integration of the 2nd argument of the function


<a target='_blank' href='https://github.com/atteson/ParametricGK/blob/979158647f025bf89b95b2611457ce1fc951e29d/src/ParametricGK.jl#L15-L26' class='documenter-source'>source</a><br>

