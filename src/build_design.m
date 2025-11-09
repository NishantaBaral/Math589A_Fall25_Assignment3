function [A,b,meta] = build_design(y, s, N, K)
% BUILD_DESIGN  Construct LS system for N-th order difference eq + K harmonics.
%   y : Tx1 double (column)
%   s : scalar season (e.g., 12)
%   N : nonnegative integer (order of past)
%   K : nonnegative integer (# harmonics)
% Returns:
%   A : (T-N)x(2+N+2K) matrix  [1,t,lags..., cos..., sin...]
%   b : (T-N)x1 vector         [y_{N+1: T}]
%   meta : struct with fields: .rows=M, .p=p, .t=(N+1:T).'
%
    y = y(:); T = numel(y);
    M = T - N; p = 2 + N + 2*K;
    if M < p
        error('Underdetermined: T-N (= %d) must exceed p (= %d).', M, p);
    end

    % response
    b = y(N+1:T);

    % time index 
    t = (N+1:T).';

    % design matrix
    A = zeros(M, p);
    col = 1;

    %intercept
    A(:, col) = 1; 
    col = col + 1;

    %linear trend
    A(:, col) = t; 
    col = col + 1;

    %lag columns: y_{t-1},...,y_{t-N}
    for i = 1:N
        A(:, col) = y(N+1-i : T-i);
        col = col + 1;
    end

    %cosine harmonics: cos(2*pi*k*t/s), k=1..K
    for k = 1:K
        A(:, col) = cos(2*pi*k*t/s);
        col = col + 1;
    end

    %sine harmonics: sin(2*pi*k*t/s), k=1..K
    for k = 1:K
        A(:, col) = sin(2*pi*k*t/s);
        col = col + 1;
    end

    meta = struct('rows', M, 'p', p, 't', t);
end






