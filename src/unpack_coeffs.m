function coef = unpack_coeffs(beta, N, K)
% UNPACK_COEFFS  Unpacks and sorts best-fit coefficients for the
% N-th order difference eq (with K seasonal harmonics).
%
%   beta : (2K+N+2)x1 double; coefficients of best fit
%   N : nonnegative integer; number of lag terms
%   K : nonnegative integer; number of seasonal harmonics
%
% Returns:
%   coef: struct with fields:
%       .c: Scalar; constant term
%       .d: Scalar; coefficient of time index 
%       .a: Length N vector; coefficients of lag
%       .alpha: Length K vector; coefficients of cosine
%               seasonal harmonics
%       .beta: Length K vector; coefficients of sine
%              seasonal harmonics
%
    coef.c = beta(1);
    coef.d = beta(2);
    coef.a = beta(3:N+2);
    coef.alpha = beta(N+2+1 : N+K+2);
    coef.beta  = beta(N+K+2+1 : N+2*K+2);
end