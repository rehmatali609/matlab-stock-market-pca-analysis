function part1_floating_point_errors(prices)
% =========================================================================
%  PART 1 - Floating-Point Arithmetic & Error Propagation
%
%  Context: When computing stock returns, accumulated floating-point errors
%  can lead to incorrect financial decisions. Here we demonstrate:
%    (a) Absolute & relative error in daily return computation
%    (b) Error propagation through cumulative return
% =========================================================================

fprintf('--- PART 1: Floating-Point Errors & Error Propagation ---\n');

N = length(prices);

%% (a) Daily Returns
% True daily return: r_i = (P_i - P_{i-1}) / P_{i-1}
daily_returns = diff(prices) ./ prices(1:end-1);

% Simulate "measured" prices with small rounding (e.g., broker rounds to 2 dp)
measured_prices = round(prices, 2);
measured_returns = diff(measured_prices) ./ measured_prices(1:end-1);

% Absolute and Relative errors in returns
abs_error = abs(daily_returns - measured_returns);
rel_error = abs_error ./ (abs(daily_returns) + eps);   % eps avoids /0

fprintf('  Average Absolute Error in Daily Returns : %.6f\n', mean(abs_error));
fprintf('  Average Relative Error in Daily Returns : %.4f%%\n', mean(rel_error)*100);

%% (b) Cumulative Return Error Propagation
cum_true     = cumprod(1 + daily_returns);
cum_measured = cumprod(1 + measured_returns);
cum_error    = abs(cum_true - cum_measured);

fprintf('  Max Cumulative Return Error (60 days)   : %.6f\n', max(cum_error));

%% Plot
figure('Name','Part 1 - Floating Point Error');
subplot(2,1,1);
plot(1:N-1, abs_error, 'r-o', 'MarkerSize', 3);
title('Absolute Error in Daily Returns (True vs Rounded Prices)');
xlabel('Trading Day'); ylabel('Absolute Error');
grid on;

subplot(2,1,2);
plot(1:N-1, cum_error, 'b-');
title('Cumulative Return Error Propagation Over 60 Days');
xlabel('Trading Day'); ylabel('Cumulative Error');
grid on;

saveas(gcf, 'plots/part1_floating_point.png');
fprintf('  [Plot saved: plots/part1_floating_point.png]\n\n');
end
