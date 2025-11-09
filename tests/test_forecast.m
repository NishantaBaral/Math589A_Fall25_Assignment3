function yhat_range = test_forecast(t0, t1, s, Ngrid, Kgrid, criterion)
% test_forecast  Fit on data/y_example.csv and predict for t = t0..t1.
% Defaults: t0=100, t1=120, s=12, Ngrid=0:3, Kgrid=0:3, criterion='bic'.
%
% Uses your repo functions in ./src:
%   build_design.m, qr_solve_dense.m, unpack_coeffs.m, fit_once.m,
%   score_model.m, select_model.m
%
% Returns:
%   yhat_range: column vector of length (t1-t0+1) with predictions at t=t0..t1.

    if nargin < 1 || isempty(t0), t0 = 100; end
    if nargin < 2 || isempty(t1), t1 = 120; end
    if nargin < 3 || isempty(s),  s  = 12;  end
    if nargin < 4 || isempty(Ngrid), Ngrid = 0:3; end
    if nargin < 5 || isempty(Kgrid), Kgrid = 0:3; end
    if nargin < 6 || isempty(criterion), criterion = 'bic'; end

    % --- Ensure src/ is on path ---
    here = fileparts(mfilename('fullpath'));
    srcDir = fullfile(here, 'src');
    if exist(srcDir, 'dir'), addpath(srcDir); end

    % --- Find y_example.csv in data/ (or common fallbacks) ---
    candidates = {
        fullfile(here, 'data', 'y_example.csv')
        fullfile(pwd,  'data', 'y_example.csv')
        fullfile(here, 'y_example.csv')
        fullfile(pwd,  'y_example.csv')
    };
    csvPath = '';
    for i = 1:numel(candidates)
        if exist(candidates{i}, 'file')
            csvPath = candidates{i};
            break;
        end
    end
    if isempty(csvPath)
        error('Could not find data/y_example.csv. Checked:\n%s\n', strjoin(candidates, '\n'));
    end

    % --- Load data ---
    y = readmatrix(csvPath);
    y = y(:);
    y = y(~isnan(y));
    T = numel(y);

    % --- Fit best model using your pipeline ---
    best = select_model(y, s, Ngrid, Kgrid, criterion);
    coef = best.coef;
    if ~isfield(coef, 'beta'), coef.beta = zeros(size(coef.alpha)); end

    % --- Predict exactly per framework for t = t0..t1 ---
    yhat_range = zeros(t1 - t0 + 1, 1);
    % History starts with observed data; we append forecasts only when t > T.
    yhist = y;

    for t = t0:t1
        % Seasonal (deterministic in t)
        sea = 0;
        for k = 1:numel(coef.alpha)
            ang = 2*pi*k*t/s;
            sea = sea + coef.alpha(k)*cos(ang) + coef.beta(k)*sin(ang);
        end
        % Intercept + trend
        acc = coef.c + coef.d*t + sea;

        % AR(N) lags: always read y_{t-i} from yhist
        for i = 1:numel(coef.a)
            acc = acc + coef.a(i) * yhist(t - i);
        end

        yhat_range(t - t0 + 1) = acc;

        % Append to history only for true forecasts (t > T)
        if t > T
            % (yhist is already long enough because we iterate in increasing t)
            yhist(t,1) = acc;
        end
    end

    % Print a small preview
    fprintf('Predictions t=%d..%d (len=%d):\n', t0, t1, numel(yhat_range));
    disp(yhat_range(1:min(10,end))');
end
