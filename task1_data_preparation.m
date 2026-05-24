function [X_original, stock_names, time_days] = task1_data_preparation(SNR_value)
% =========================================================================
%  TASK 1: DATA PREPARATION & NOISE GENERATION
%  CLO 1 - Understand and arrange data in proper matrix-vector form
%  
%  Description:
%    1. Generate/load multi-stock dataset (multiple dimensions)
%    2. Arrange in proper matrix-vector form: n_samples x n_features
%    3. Calculate and generate Gaussian noise with given SNR
%    4. Create noisy dataset
% =========================================================================

fprintf('  [Task 1: Data Preparation & Noise Generation]\n\n');

%% Step 1: Generate Synthetic Stock Data (Multiple Stocks)
% Create a realistic multi-stock dataset
% Dataset: Historical daily returns of 8 stocks over 250 trading days
rng(42);  % Reproducible seed

n_stocks = 8;          % Number of stocks (features/dimensions)
n_days = 250;          % Number of trading days (samples)

stock_names = {'AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA', 'META', 'NFLX', 'NVIDIA'};
time_days = (1:n_days)';

% Generate correlated stock prices (more realistic)
fprintf('  Creating synthetic multi-stock dataset...\n');
fprintf('    Dimensions: %d stocks (features) x %d trading days (samples)\n', n_stocks, n_days);

% Generate base trend with different drift rates for each stock
base_prices = zeros(n_days, n_stocks);
for i = 1:n_stocks
    drift = 0.0005 + (i-1) * 0.0002;  % Different drift per stock
    volatility = 0.015 + randn() * 0.005;  % Random volatility
    base_prices(:, i) = 100 * exp(cumsum([zeros(1,1); drift + volatility * randn(n_days-1, 1)]));
end

% Normalize prices to create returns-like features
X_original = zeros(n_days, n_stocks);
for i = 1:n_stocks
    % Daily log-returns: easier for statistical analysis
    returns = diff(log(base_prices(:, i)));
    X_original(2:end, i) = returns;
    X_original(1, i) = 0;  % First day has zero return
end

% Center and standardize the data
fprintf('  Standardizing data (zero mean, unit variance)...\n');
X_original = (X_original - mean(X_original)) ./ std(X_original);

fprintf('  Original data shape: [%d x %d] (samples x features)\n', size(X_original, 1), size(X_original, 2));

%% Step 2: Calculate Signal Power and Noise Variance
fprintf('\n  SNR Calculation and Noise Generation:\n');
fprintf('    SNR Value: %d\n', SNR_value);

% Signal power (variance of original data)
signal_power = mean(var(X_original));
fprintf('    Signal Power (mean variance): %.6f\n', signal_power);

% Calculate noise variance from SNR
% SNR_dB = 20 * log10(sqrt(signal_power / noise_power))
% SNR_dB = SNR_value (as calculated from registration numbers)
SNR_linear = 10^(SNR_value / 20);  % Convert dB to linear scale
noise_variance = signal_power / (SNR_linear^2);
noise_std = sqrt(noise_variance);

fprintf('    SNR (linear): %.4f\n', SNR_linear);
fprintf('    Noise Std Dev: %.6f\n', noise_std);

%% Step 3: Generate Gaussian Noise and Create Noisy Dataset
fprintf('\n  Generating Gaussian noise with SNR = %d...\n', SNR_value);

% Gaussian noise matrix (same size as original data)
noise = noise_std * randn(size(X_original));

% Noisy dataset
X_noisy = X_original + noise;

fprintf('    Noise shape: [%d x %d]\n', size(noise, 1), size(noise, 2));
fprintf('    Noisy data shape: [%d x %d]\n', size(X_noisy, 1), size(X_noisy, 2));

%% Step 4: Save Datasets
fprintf('\n  Saving datasets...\n');

% Ensure data directory exists
if ~exist('data', 'dir')
    mkdir('data');
end

save('data/X_original.mat', 'X_original', 'stock_names', 'time_days');
save('data/X_noisy.mat', 'X_noisy', 'SNR_value');

%% Step 5: Display Data Statistics
fprintf('\n  DATA STATISTICS:\n');
fprintf('  %-15s | %10s | %10s | %10s\n', 'Stock', 'Mean', 'Std Dev', 'Min');
fprintf('  %s\n', repmat('-', 1, 55));
for i = 1:n_stocks
    fprintf('  %-15s | %10.6f | %10.6f | %10.6f\n', stock_names{i}, ...
        mean(X_original(:,i)), std(X_original(:,i)), min(X_original(:,i)));
end

fprintf('\n  Original Data - Covariance Matrix (1st 4x4):\n');
cov_matrix = cov(X_original);
disp(cov_matrix(1:4, 1:4));

fprintf('\n  [TASK 1 COMPLETED]\n\n');

end
