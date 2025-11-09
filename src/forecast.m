function yF = forecast(y, s, coef, H)
    % Forecast h=1..H using:
    % yhat_t = c + d*t + sum_i a_i*y_{t-i} + sum_k (alpha_k cos(2πkt/s) + beta_k sin(2πkt/s))
    % and for t-i > T, use previously predicted values.

    y = double(y(:));
    T = numel(y);
    N = numel(coef.a);
    K = numel(coef.alpha);
    if ~isfield(coef, 'beta')
        coef.beta = zeros(size(coef.alpha));
    end

    yF = zeros(H,1);
    % Combined observed+forecast history so y_{t-i} is always a direct read
    yhist = [y; zeros(H,1)];  % indices 1..T are data, T+1..T+H will be filled

    for h = 1:H
        t = T + h;  % absolute time index

        % seasonal term (deterministic in t)
        sea = 0;
        for k = 1:K
            ang = 2*pi*k*t/s;
            sea = sea + coef.alpha(k)*cos(ang) + coef.beta(k)*sin(ang);
        end

        % intercept + linear trend
        acc = coef.c + coef.d*t + sea;

        % AR(N) lags: ALWAYS read from the growing history
        % (No if/else; by construction t-i >= 1 since T >= N)
        for i = 1:N
            acc = acc + coef.a(i) * yhist(t - i);
        end

        yhist(t) = acc;   % commit this step so future lags see it
        yF(h)    = acc;
    end
end
