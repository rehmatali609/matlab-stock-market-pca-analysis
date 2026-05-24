function part5_differentiation_integration(days, prices)
% =========================================================================
%  PART 5 - Numerical Differentiation & Integration
%
%  Context:
%    - Differentiation  → Rate of change of stock price (momentum/velocity)
%    - Second Derivative → Acceleration (detect turning points / peaks)
%    - Integration       → Total accumulated return (area under price curve)
%
%  Methods: Forward, Backward, Central Differences; Trapezoidal Rule;
%           Simpson's 1/3 Rule
% =========================================================================

fprintf('--- PART 5: Numerical Differentiation & Integration ---\n');

x = days;
y = prices;
h = x(2) - x(1);    % Step size = 1 day
n = length(x);

%% ---- Differentiation ----
% First derivative (velocity of price change)
dy_forward  = zeros(n,1);
dy_backward = zeros(n,1);
dy_central  = zeros(n,1);

for i = 1:n
    if i < n
        dy_forward(i)  = (y(i+1) - y(i)) / h;
    else
        dy_forward(i)  = dy_forward(i-1);
    end
    if i > 1
        dy_backward(i) = (y(i) - y(i-1)) / h;
    else
        dy_backward(i) = dy_backward(i+1);
    end
    if i > 1 && i < n
        dy_central(i)  = (y(i+1) - y(i-1)) / (2*h);
    else
        dy_central(i)  = dy_forward(i);
    end
end

% Second derivative (acceleration)
d2y = zeros(n,1);
for i = 2:n-1
    d2y(i) = (y(i+1) - 2*y(i) + y(i-1)) / h^2;
end
d2y(1) = d2y(2); d2y(n) = d2y(n-1);

% Identify turning points (sign change in first derivative)
sign_changes = find(diff(sign(dy_central)) ~= 0);
fprintf('  Turning points detected at days: ');
fprintf('%d ', x(sign_changes)); fprintf('\n');

%% ---- Integration ----
% Total "price area" = approximation of accumulated value

% Trapezoidal Rule
trap_area = trapz(x, y);

% Simpson's 1/3 Rule (requires odd number of intervals; ensure even N)
if mod(n,2) == 0
    xs = x(1:end-1); ys = y(1:end-1); ns = length(xs);
else
    xs = x; ys = y; ns = n;
end
simp_area = (h/3) * (ys(1) + 4*sum(ys(2:2:ns-1)) + 2*sum(ys(3:2:ns-2)) + ys(ns));

fprintf('  Total Accumulated Price Area:\n');
fprintf('    Trapezoidal Rule : %.2f\n', trap_area);
fprintf('    Simpson 1/3 Rule : %.2f\n', simp_area);
fprintf('    Difference       : %.6f\n', abs(trap_area - simp_area));

%% Plot
figure('Name','Part 5 - Differentiation & Integration');

subplot(3,1,1);
plot(x, y, 'k-', 'LineWidth', 1.2);
title('Stock Price'); xlabel('Day'); ylabel('Price ($)'); grid on;

subplot(3,1,2);
plot(x, dy_forward,  'r-', 'DisplayName', 'Forward'); hold on;
plot(x, dy_backward, 'b--','DisplayName', 'Backward');
plot(x, dy_central,  'g-', 'DisplayName', 'Central');
yline(0, 'k:'); title('First Derivative (Price Velocity)');
xlabel('Day'); ylabel('dP/dt'); legend; grid on;

subplot(3,1,3);
plot(x, d2y, 'm-', 'LineWidth', 1.2);
yline(0, 'k:'); title('Second Derivative (Price Acceleration / Turning Points)');
xlabel('Day'); ylabel('d²P/dt²'); grid on;

saveas(gcf, 'plots/part5_diff_integ.png');
fprintf('  [Plot saved: plots/part5_diff_integ.png]\n\n');
end
