function yF = forecast(y, s, coef, H)
% FORECAST     Given some data y, a seasonal period s, 
% and a set of coefficients describing a model of best fit,
% forecast the behavior of the time series beyond the last
% given datapoint.
%
% Parameters:
%   y = length T vector; scalar time series data 
%   s = scalar; period of season in terms of number of timesteps
%   coef: struct with fields:
%       .c: Scalar; constant term
%       .d: Scalar; coefficient of time index 
%       .a: Length N vector; coefficients of lag
%       .alpha: Length K vector; coefficients of cosine
%               seasonal harmonics
%       .beta: Length K vector; coefficients of sine
%              seasonal harmonics
%   H = nonnegative integer; number of timesteps to forecast
%
% Returns:
%   yF = length H vector; the forecasted time series response
%
y = y(:);               % Time series data
T = numel(y);           % Number of timesteps in data  
N = numel(coef.a);      % Number of lag elements in model
K = numel(coef.alpha);  % Number of seasonal harmonics in model

% Create forecasted time series response vector 
% using a recursive prediction process
yF = zeros(H,1);
for h = 1:H
    t = T + h;

    % Compute the seasonal component at this timestep
    seasonal = 0;
    for k=1:K
        seasonal = seasonal + coef.alpha(k)*cos(2*pi*k*t/s) + coef.beta(k)*sin(2*pi*k*t/s);
    end

    % Compute constant/linear component at this timestep
    prediction = coef.c + coef.d * t + seasonal;

    % Compute lag component using recursive prediction
    % (that is, use original data if available at a given timestep;
    % otherwise, use previous forecastd data at that timestep)
    for i = 1:N
        if h-i <= 0
            prediction = prediction + coef.a(i)*y(T-(i-1));
        else
            prediction = prediction + coef.a(i)*yF(h-i);
        end
    end
    yF(h) = prediction;
end
end