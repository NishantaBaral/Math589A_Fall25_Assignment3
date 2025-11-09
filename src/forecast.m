function yF = forecast(y, s, coef, H)
    y = y(:); T = numel(y);
    N = numel(coef.a); K = numel(coef.alpha);
    if ~isfield(coef, 'beta'), coef.beta = zeros(size(coef.alpha)); end
    yF = zeros(H,1);
    history = [y; zeros(H,1)];
    for h = 1:H
        t = T + h;
        sea = 0;
        for k = 1:K
            sea = sea + coef.alpha(k)*cos(2*pi*k*t/s) + coef.beta(k)*sin(2*pi*k*t/s);
        end
        acc = coef.c + coef.d*t + sea;
        for i = 1:N
            tau = t - i;
            if tau >= 1
                acc = acc + coef.a(i) * history(tau);
            end
        end
        history(T + h) = acc;
        yF(h) = acc;
    end
end