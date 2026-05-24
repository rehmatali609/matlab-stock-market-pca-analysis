function part4_curve_fitting(days, prices)
% =========================================================================
%  PART 4 - Curve Fitting (Least Squares Approximation)
%
%  Context: Fitting a trend line or polynomial to historical stock prices
%  to identify the underlying trend and make short-term forecasts.
%
%  Methods: Linear Least Squares, Polynomial Least Squares (degree 2 & 3)
% =========================================================================

fprintf('--- PART 4: Curve Fitting (Least Squares Trend Analysis) ---\n');

x = days;
y = prices;
n = length(x);

%% Linear Fit  (y = a0 + a1*x)
A_lin = [ones(n,1), x];
coef_lin = (A_lin' * A_lin) \ (A_lin' * y);   % Normal equations
y_lin = A_lin * coef_lin;

%% Polynomial Fit Degree 2
A_poly2 = [ones(n,1), x, x.^2];
coef_p2 = (A_poly2' * A_poly2) \ (A_poly2' * y);
y_poly2 = A_poly2 * coef_p2;

%% Polynomial Fit Degree 3
A_poly3 = [ones(n,1), x, x.^2, x.^3];
coef_p3 = (A_poly3' * A_poly3) \ (A_poly3' * y);
y_poly3 = A_poly3 * coef_p3;

%% R-squared values
SS_tot = sum((y - mean(y)).^2);
R2_lin  = 1 - sum((y - y_lin).^2)  / SS_tot;
R2_p2   = 1 - sum((y - y_poly2).^2)/ SS_tot;
R2_p3   = 1 - sum((y - y_poly3).^2)/ SS_tot;

fprintf('  Linear Fit   R^2 = %.4f  |  Coefficients: a0=%.3f, a1=%.4f\n', ...
        R2_lin, coef_lin(1), coef_lin(2));
fprintf('  Poly Deg-2   R^2 = %.4f\n', R2_p2);
fprintf('  Poly Deg-3   R^2 = %.4f\n', R2_p3);

%% Forecast next 10 days
x_fut  = (max(x)+1 : max(x)+10)';
y_fut_lin  = [ones(10,1), x_fut] * coef_lin;
y_fut_p3   = [ones(10,1), x_fut, x_fut.^2, x_fut.^3] * coef_p3;

fprintf('  10-Day Forecast (Linear)  : Day %d price ~ $%.2f\n', ...
        x_fut(end), y_fut_lin(end));
fprintf('  10-Day Forecast (Poly-3)  : Day %d price ~ $%.2f\n', ...
        x_fut(end), y_fut_p3(end));

%% Plot
figure('Name','Part 4 - Curve Fitting');
plot(x, y, 'k.', 'MarkerSize', 6, 'DisplayName', 'Historical Prices'); hold on;
plot(x, y_lin,   'r-', 'LineWidth', 1.5, 'DisplayName', sprintf('Linear (R²=%.3f)',R2_lin));
plot(x, y_poly2, 'b--','LineWidth', 1.5, 'DisplayName', sprintf('Poly-2 (R²=%.3f)',R2_p2));
plot(x, y_poly3, 'g-', 'LineWidth', 1.5, 'DisplayName', sprintf('Poly-3 (R²=%.3f)',R2_p3));
plot(x_fut, y_fut_p3, 'm--o', 'LineWidth', 1.2, 'DisplayName', 'Poly-3 Forecast');
xline(max(x), 'k:', 'Today', 'LabelVerticalAlignment','bottom');
title('Stock Price Curve Fitting & Forecast (Least Squares)');
xlabel('Trading Day'); ylabel('Price ($)');
legend('Location','northwest'); grid on;
saveas(gcf, 'plots/part4_curve_fitting.png');
fprintf('  [Plot saved: plots/part4_curve_fitting.png]\n\n');
end
