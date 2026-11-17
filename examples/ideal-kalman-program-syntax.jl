# Kalman Filter Example
## The following is ideal syntax using indexing of random variables
pbar( x[k] )        = ∑(x[k])( f(x[k] | x[k-1] ) * p(x[k-1]) )
joint( x[k], y[k] ) = pbar( x[k] ) * g( y[k] | x[k] )
bayes( x[k]| y[k] ) = joint(x[k], y[k]) / ∑(x[k])( joint( x[k], y[k] ) )
p( x[k] )           = ∑(y[k])( bayes(x[k] | y[k]) * meas( y[k] ) )

## The following is what markovcats can currently handle
pbar(xnext)       = ∑(x)( f( xnext | x ) * p(x) )
joint( xnext, y ) = pbar( xnext ) * g( y | xnext )
bayes(xnext | y)  = joint(xnext, y) / ∑(xnext)( joint( xnext, y ) )
p_next( xnext )   = ∑(y)( bayes(xnext | y) * meas( y ) )




# Simpler Example: Random Walk
x :: Set{String}(["Peppermint Forest", "Gumdrop Mountains", "Lollipop Woods"])

p(x[0]) ~ FinProb([0.5, 0.5, 0])
f(xnext | x) = [.25, .3, .45;
                .50, .20, .30;
                .10, .10, .80]

f(y|x) * p(x)

p(xnext) = ∑(x)( f(xnext | x) * p(x) )
