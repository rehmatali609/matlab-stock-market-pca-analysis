function part8_ode_stock_model()
% =========================================================================
%  PART 8 - Numerical Solution of ODEs
%
%  Context: Geometric Brownian Motion (GBM) is the standard ODE model
%  for stock prices:
%
%    dS/dt = mu*S + sigma*S*noise(t)
%
%  In deterministic form (mean path):
%    dS/dt = mu * S(t)       →  S(t) = S0 * exp(mu*t)
%
%  We solve this ODE numerically and compare with exact solution.
%
%  Methods: Euler's Method, Runge-Kutta 4 (RK4)
% =========================================================================

fprintf('--- PART 8: ODE Solution (Stock Price GBM Model) ---\n');

% Parameters
S0    = 100;      % Initial price
mu    = 0.012;    % Daily drift (growth rate)
sigma = 0.02;     % Volatility
T     = 60;       % Total days
h     = 1;        % Step size (1 day)
t     = 0:h:T;
n     = length(t);

% ODE: dS/dt = mu * S   (deterministic mean path)
f = @(t_val, S) mu * S;

% Exact solution
S_exact = S0 * exp(mu * t);

%% Euler's Method
S_euler = zeros(1,n);
S_euler(1) = S0;
for i = 1:n-1
    S_euler(i+1) = S_euler(i) + h * f(t(i), S_euler(i));
end

%% RK4 Method
S_rk4 = zeros(1,n);
S_rk4(1) = S0;
for i = 1:n-1
    k1 = f(t(i),       S_rk4(i));
    k2 = f(t(i)+h/2,   S_rk4(i) + h/2*k1);
    k3 = f(t(i)+h/2,   S_rk4(i) + h/2*k2);
    k4 = f(t(i)+h,     S_rk4(i) + h*k3);
    S_rk4(i+1) = S_rk4(i) + (h/6)*(k1 + 2*k2 + 2*k3 + k4);
end

%% GBM Stochastic Simulation (Monte Carlo, 10 paths)
rng(42);
n_paths = 10;
S_gbm = zeros(n_paths, n);
S_gbm(:,1) = S0;
for p = 1:n_paths
    for i = 1:n-1
        dW = randn() * sqrt(h);
        S_gbm(p,i+1) = S_gbm(p,i) + mu*S_gbm(p,i)*h + sigma*S_gbm(p,i)*dW;
    end
end

%% Errors
err_euler = abs(S_euler - S_exact);
err_rk4   = abs(S_rk4   - S_exact);
fprintf('\n  Final price (Day %d):\n', T);
fprintf('    Exact  : $%.4f\n', S_exact(end));
fprintf('    Euler  : $%.4f  |  Global Error: %.4f\n', S_euler(end), err_euler(end));
fprintf('    RK4    : $%.4f  |  Global Error: %.6f\n', S_rk4(end),   err_rk4(end));
fprintf('\n  RK4 is %.0fx more accurate than Euler here.\n', ...
        err_euler(end)/max(err_rk4(end),eps));

%% Plots
figure('Name','Part 8 - ODE Stock Model');

subplot(2,2,1);
plot(t, S_exact, 'k-', 'LineWidth', 2, 'DisplayName', 'Exact'); hold on;
plot(t, S_euler, 'r--','LineWidth', 1.5, 'DisplayName', 'Euler');
plot(t, S_rk4,   'b:','LineWidth', 2, 'DisplayName', 'RK4');
title('ODE Solution: dS/dt = \mu S'); xlabel('Day'); ylabel('Price ($)');
legend; grid on;

subplot(2,2,2);
semilogy(t, err_euler+eps, 'r-', 'DisplayName', 'Euler Error'); hold on;
semilogy(t, err_rk4+eps,   'b-', 'DisplayName', 'RK4 Error');
title('Global Error (log scale)'); xlabel('Day'); ylabel('|Error|');
legend; grid on;

subplot(2,2,[3,4]);
for p = 1:n_paths
    plot(t, S_gbm(p,:), 'Color', [0.4 0.6 0.9 0.5]); hold on;
end
plot(t, S_exact, 'k-', 'LineWidth', 2, 'DisplayName', 'Mean Path (Exact)');
title(sprintf('GBM Monte Carlo Simulation (%d paths, \\mu=%.3f, \\sigma=%.2f)', ...
      n_paths, mu, sigma));
xlabel('Trading Day'); ylabel('Price ($)');
legend('Location','northwest'); grid on;

saveas(gcf, 'plots/part8_ode_stock_model.png');
fprintf('  [Plot saved: plots/part8_ode_stock_model.png]\n\n');
end
