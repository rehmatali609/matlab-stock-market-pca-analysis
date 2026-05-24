function part2_root_finding(prices)
% =========================================================================
%  PART 2 - Root-Finding Methods
%
%  Context: Finding the Break-Even stock price where:
%    NPV(price) = 0
%  i.e., the price at which an investment's net present value equals zero.
%
%  We define:
%    f(x) = PV of future cash flows - initial investment
%           = sum(CF_t / (1+r)^t) - x
%  where r = 0.01 (monthly discount rate), CF_t = expected future returns.
%
%  Methods used: Bisection, Newton-Raphson, Secant
% =========================================================================

fprintf('--- PART 2: Root-Finding (Break-Even Stock Price) ---\n');

% Parameters
r   = 0.01;                       % Discount rate per period
N   = length(prices);
CF  = diff(prices);               % Cash flows = daily price changes
t   = (1:length(CF))';

% NPV function: f(x) = sum(CF/(1+r)^t) - x
PV_cashflows = sum(CF ./ (1+r).^t);

% f(x) = PV_cashflows - x;  root is x* = PV_cashflows
% We add a small nonlinearity to make it a genuine root problem:
% f(x) = PV_cashflows - x - 0.5*(x - 100)^0.5   [only valid x > 100]
f  = @(x) PV_cashflows - x - 0.5*sqrt(abs(x - 100) + eps);
df = @(x) -1 - 0.5*(0.5)*(sign(x-100))./sqrt(abs(x-100) + eps);

a = 50; b = 200; tol = 1e-6; max_iter = 100;

%% Bisection Method
fprintf('\n  [Bisection Method]\n');
[root_b, iter_b, err_b] = bisection_method(f, a, b, tol, max_iter);
fprintf('  Root = %.6f  |  Iterations = %d\n', root_b, iter_b);

%% Newton-Raphson Method
fprintf('\n  [Newton-Raphson Method]\n');
x0 = 120;
[root_nr, iter_nr, err_nr] = newton_raphson(f, df, x0, tol, max_iter);
fprintf('  Root = %.6f  |  Iterations = %d\n', root_nr, iter_nr);

%% Secant Method
fprintf('\n  [Secant Method]\n');
x0 = 100; x1 = 150;
[root_s, iter_s, err_s] = secant_method(f, x0, x1, tol, max_iter);
fprintf('  Root = %.6f  |  Iterations = %d\n', root_s, iter_s);

%% Convergence Comparison Plot
figure('Name','Part 2 - Root Finding Convergence');
semilogy(1:length(err_b),  err_b,  'r-o', 'DisplayName', 'Bisection');  hold on;
semilogy(1:length(err_nr), err_nr, 'b-s', 'DisplayName', 'Newton-Raphson');
semilogy(1:length(err_s),  err_s,  'g-^', 'DisplayName', 'Secant');
title('Root-Finding Convergence Comparison');
xlabel('Iteration'); ylabel('|f(x)| (log scale)');
legend; grid on;
saveas(gcf, 'plots/part2_root_finding.png');
fprintf('\n  [Plot saved: plots/part2_root_finding.png]\n\n');
end

% ------------------------------------------------------------------
function [root, iter, errors] = bisection_method(f, a, b, tol, max_iter)
    errors = [];
    for iter = 1:max_iter
        c = (a + b) / 2;
        fc = f(c);
        errors(end+1) = abs(fc);
        if abs(fc) < tol || (b-a)/2 < tol
            root = c; return;
        end
        if sign(fc) == sign(f(a)), a = c; else, b = c; end
    end
    root = (a+b)/2;
end

function [root, iter, errors] = newton_raphson(f, df, x0, tol, max_iter)
    x = x0; errors = [];
    for iter = 1:max_iter
        fx = f(x); dfx = df(x);
        errors(end+1) = abs(fx);
        if abs(fx) < tol, root = x; return; end
        x = x - fx/dfx;
    end
    root = x;
end

function [root, iter, errors] = secant_method(f, x0, x1, tol, max_iter)
    errors = [];
    for iter = 1:max_iter
        fx0 = f(x0); fx1 = f(x1);
        errors(end+1) = abs(fx1);
        if abs(fx1) < tol, root = x1; return; end
        x2 = x1 - fx1*(x1-x0)/(fx1-fx0);
        x0 = x1; x1 = x2;
    end
    root = x1;
end
