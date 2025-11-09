function yF = forecast(y, s, coef, H)
y = y(:); T = numel(y); N = numel(coef.a); K = numel(coef.alpha);
yF = zeros(H,1);
for h = 1:H
    t = T + h;                                % absolute time for BOTH trend and season
    % season
    sea = 0;
    for k = 1:K
        sea = sea + coef.alpha(k)*cos(2*pi*k*t/s) + coef.beta(k)*sin(2*pi*k*t/s);
    end
    % intercept + trend (absolute t)
    acc = coef.c + coef.d*t + sea;
    % AR lags
    for i = 1:N
        idx = t - i;                          % y_{t-i}
        if idx <= T
            acc = acc + coef.a(i)*y(idx);     % use actual data
        else
            acc = acc + coef.a(i)*yF(idx - T);% use prior forecasts
        end
    end
    yF(h) = acc;
end
end
