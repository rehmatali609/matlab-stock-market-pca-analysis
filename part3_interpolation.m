function part3_interpolation(days, prices)
% =========================================================================
%  PART 3 - Interpolation
%
%  Context: Stock data is available only on trading days. We use
%  interpolation to estimate prices on missing/intermediate days and
%  to reconstruct a smooth price curve.
%
%  Methods: Lagrange Polynomial Interpolation, Cubic Spline Interpolation
% =========================================================================

fprintf('--- PART 3: Interpolation (Stock Price Estimation) ---\n');

% Use every 5th day as "known" data points (sparse sampling)
idx_known = 1:5:length(days);
x_known   = days(idx_known);
y_known   = prices(idx_known);

% Dense query points
x_query = linspace(1, max(days), 300)';

%% Lagrange Interpolation
y_lagrange = lagrange_interp(x_known, y_known, x_query);

%% Cubic Spline (MATLAB built-in)
cs       = spline(x_known, y_known);
y_spline = ppval(cs, x_query);

%% Error vs. true prices at original day points
y_lag_at_days    = lagrange_interp(x_known, y_known, days);
y_spline_at_days = ppval(cs, days);

err_lag   = mean(abs(prices - y_lag_at_days));
err_spline= mean(abs(prices - y_spline_at_days));

fprintf('  Lagrange  MAE vs true prices : %.4f\n', err_lag);
fprintf('  Cub. Spline MAE vs true prices: %.4f\n', err_spline);

%% Plot
figure('Name','Part 3 - Interpolation');
plot(days, prices, 'k.', 'MarkerSize', 8, 'DisplayName', 'True Prices'); hold on;
plot(x_known, y_known, 'rs', 'MarkerSize', 10, 'DisplayName', 'Known Points');
plot(x_query, y_lagrange, 'b--', 'LineWidth', 1.2, 'DisplayName', 'Lagrange');
plot(x_query, y_spline,   'g-',  'LineWidth', 1.5, 'DisplayName', 'Cubic Spline');
title('Stock Price Interpolation');
xlabel('Trading Day'); ylabel('Price ($)');
legend('Location','northwest'); grid on;
saveas(gcf, 'plots/part3_interpolation.png');
fprintf('  [Plot saved: plots/part3_interpolation.png]\n\n');
end

% ------------------------------------------------------------------
function y_out = lagrange_interp(x_nodes, y_nodes, x_query)
% Lagrange polynomial interpolation
    n = length(x_nodes);
    y_out = zeros(size(x_query));
    for i = 1:n
        L = ones(size(x_query));
        for j = 1:n
            if j ~= i
                L = L .* (x_query - x_nodes(j)) / (x_nodes(i) - x_nodes(j));
            end
        end
        y_out = y_out + y_nodes(i) * L;
    end
end
