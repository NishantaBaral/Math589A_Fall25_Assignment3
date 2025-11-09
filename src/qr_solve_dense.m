function x = qr_solve_dense(A,b)
    [m,n] = size(A);
    R = A; y = b;
    for k = 1:n
        v = R(k:end,k);
        nv = norm(v);
        if nv == 0
            continue
        end
        s = sign(v(1)); if s==0, s = 1; end
        alpha = -s * nv;
        v(1) = v(1) - alpha;
        nv2 = norm(v);
        if nv2 == 0
            continue
        end
        v = v / nv2;
        R(k:end,k:end) = R(k:end,k:end) - 2 * (v * (v.' * R(k:end,k:end)));
        y(k:end)       = y(k:end)       - 2 * (v * (v.' * y(k:end)));
    end
    R = triu(R(1:n,1:n)); y = y(1:n);
    x = zeros(n,1);
    for i = n:-1:1
        x(i) = (y(i) - R(i,i+1:end)*x(i+1:end)) / R(i,i);
    end
end
