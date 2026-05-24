function part6_linear_systems(prices)
% =========================================================================
%  PART 6 - Solution of Linear Systems
%
%  Context: Portfolio Optimization — Find weights w = [w1, w2, w3, w4]
%  for 4 assets such that the portfolio achieves target return and risk.
%
%  We set up a linear system: A * w = b
%  where A encodes return expectations and constraints,
%        b encodes the desired portfolio properties.
%
%  Methods: Gaussian Elimination (manual), LU Decomposition (manual),
%           Verification with MATLAB backslash
% =========================================================================

fprintf('--- PART 6: Linear Systems (Portfolio Weight Allocation) ---\n');

% Simulate 4 stock return vectors (each 60 days, derived from prices)
rng(7);
n = length(prices);
R = [prices/100, ...
     (prices + randn(n,1)*2)/100, ...
     (prices*0.8 + randn(n,1)*3)/100, ...
     (prices*1.2 + randn(n,1)*1.5)/100];

% Mean returns and covariance
mu  = mean(R)';          % 4x1
Sig = cov(R);            % 4x4 covariance matrix

% System: Sig * w = mu  (Markowitz-like system — maximize return per unit risk)
% Additional constraints handled by scaling:
A = Sig;
b = mu;

fprintf('\n  Linear System: Sigma * w = mu_returns\n');
fprintf('  Matrix A (Cov) size: %dx%d\n', size(A));

%% Gaussian Elimination (manual)
[w_gauss, steps_gauss] = gaussian_elimination(A, b);
fprintf('\n  [Gaussian Elimination]\n');
fprintf('  Weights: w = [%.4f, %.4f, %.4f, %.4f]\n', w_gauss);
fprintf('  Sum of weights: %.4f\n', sum(w_gauss));

%% LU Decomposition (manual)
[L, U, w_lu] = lu_decomposition(A, b);
fprintf('\n  [LU Decomposition]\n');
fprintf('  Weights: w = [%.4f, %.4f, %.4f, %.4f]\n', w_lu);
fprintf('  ||L*U - A|| residual: %.2e\n', norm(L*U - A));

%% MATLAB verification
w_matlab = A \ b;
fprintf('\n  [MATLAB backslash verification]\n');
fprintf('  Weights: w = [%.4f, %.4f, %.4f, %.4f]\n', w_matlab);
fprintf('  ||w_gauss - w_matlab|| = %.2e\n', norm(w_gauss - w_matlab));

%% Normalize weights to sum to 1 (proper portfolio)
w_norm = w_matlab / sum(abs(w_matlab));
fprintf('\n  Normalized portfolio allocation:\n');
assets = {'Stock A','Stock B','Stock C','Stock D'};
for i=1:4
    fprintf('    %s: %.1f%%\n', assets{i}, w_norm(i)*100);
end

%% Plot portfolio allocation
figure('Name','Part 6 - Portfolio Weights');
bar(w_norm * 100, 'FaceColor', [0.2 0.6 0.8]);
set(gca,'XTickLabel', assets);
title('Optimal Portfolio Weights (Linear System Solution)');
ylabel('Weight (%)'); grid on;
saveas(gcf, 'plots/part6_linear_systems.png');
fprintf('  [Plot saved: plots/part6_linear_systems.png]\n\n');
end

% ------------------------------------------------------------------
function [x, steps] = gaussian_elimination(A, b)
    n = length(b);
    Ab = [A, b];
    steps = {};
    for k = 1:n-1
        for i = k+1:n
            if Ab(k,k) == 0, error('Zero pivot'); end
            m = Ab(i,k) / Ab(k,k);
            Ab(i,:) = Ab(i,:) - m * Ab(k,:);
        end
    end
    % Back substitution
    x = zeros(n,1);
    for i = n:-1:1
        x(i) = (Ab(i,end) - Ab(i,i+1:n)*x(i+1:n)) / Ab(i,i);
    end
end

function [L, U, x] = lu_decomposition(A, b)
    n = length(b);
    L = eye(n); U = A;
    for k = 1:n-1
        for i = k+1:n
            L(i,k) = U(i,k) / U(k,k);
            U(i,:) = U(i,:) - L(i,k)*U(k,:);
        end
    end
    % Forward substitution: L*y = b
    y = zeros(n,1);
    for i = 1:n
        y(i) = b(i) - L(i,1:i-1)*y(1:i-1);
    end
    % Back substitution: U*x = y
    x = zeros(n,1);
    for i = n:-1:1
        x(i) = (y(i) - U(i,i+1:n)*x(i+1:n)) / U(i,i);
    end
end
