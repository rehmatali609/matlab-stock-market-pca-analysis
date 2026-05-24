function part7_eigenvalue_svd(prices)
% =========================================================================
%  PART 7 - Eigenvalue Problems & SVD
%
%  Context: Principal Component Analysis (PCA) of a multi-stock portfolio.
%  In finance, PCA reduces many correlated stock returns to a few
%  independent "factors" (market factor, sector factor, etc.).
%
%  Methods: Power Iteration (dominant eigenvalue), MATLAB eig(), SVD
% =========================================================================

fprintf('--- PART 7: Eigenvalue Problems & SVD (PCA on Portfolio) ---\n');

% Build 4-stock return matrix
rng(9);
n = length(prices);
R = zeros(n, 4);
R(:,1) = diff([prices(1); prices]);
R(:,2) = diff([prices(1); prices]) * 0.9 + randn(n,1)*0.3;
R(:,3) = diff([prices(1); prices]) * 0.6 + randn(n,1)*0.8;
R(:,4) = diff([prices(1); prices]) * 1.1 + randn(n,1)*0.4;

% Standardize
R = (R - mean(R)) ./ std(R);

% Covariance matrix
C = cov(R);

%% Power Iteration (finds dominant eigenvalue/vector)
fprintf('\n  [Power Iteration]\n');
[lambda_max, v_max, iters] = power_iteration(C, 1000, 1e-8);
fprintf('  Dominant eigenvalue   : %.4f\n', lambda_max);
fprintf('  Dominant eigenvector  : [%.3f, %.3f, %.3f, %.3f]\n', v_max);
fprintf('  Converged in %d iterations\n', iters);

%% Full Eigendecomposition (MATLAB)
[V, D] = eig(C);
eigenvalues = diag(D);
[eigenvalues, idx] = sort(eigenvalues, 'descend');
V = V(:, idx);

variance_explained = eigenvalues / sum(eigenvalues) * 100;
fprintf('\n  [Eigendecomposition - All Components]\n');
for i = 1:4
    fprintf('  PC%d: eigenvalue=%.4f  →  %.1f%% variance explained\n', ...
            i, eigenvalues(i), variance_explained(i));
end
fprintf('  PC1+PC2 explain %.1f%% of total portfolio variance\n', ...
        sum(variance_explained(1:2)));

%% SVD
[U_svd, S_svd, V_svd] = svd(R);
singular_vals = diag(S_svd);
fprintf('\n  [SVD Analysis]\n');
fprintf('  Top 4 singular values: %.3f  %.3f  %.3f  %.3f\n', singular_vals(1:4));

%% Low-rank reconstruction (keep top 2 components)
R_reconstructed = U_svd(:,1:2) * S_svd(1:2,1:2) * V_svd(:,1:2)';
recon_error = norm(R - R_reconstructed, 'fro') / norm(R, 'fro');
fprintf('  Rank-2 reconstruction error: %.4f (%.1f%% info retained)\n', ...
        recon_error, (1-recon_error)*100);

%% Plot
figure('Name','Part 7 - PCA / Eigenvalues / SVD');

subplot(1,3,1);
bar(eigenvalues, 'FaceColor', [0.2 0.5 0.8]);
title('Eigenvalues (Variance)'); xlabel('Component'); ylabel('\lambda');
set(gca,'XTickLabel',{'PC1','PC2','PC3','PC4'}); grid on;

subplot(1,3,2);
bar(cumsum(variance_explained), 'FaceColor', [0.1 0.7 0.4]);
title('Cumulative Variance Explained'); xlabel('Components'); ylabel('%');
set(gca,'XTickLabel',{'PC1','1-2','1-3','All'}); yline(90,'r--'); grid on;

subplot(1,3,3);
imagesc(C); colorbar;
title('Covariance Matrix of Portfolio');
set(gca,'XTickLabel',{'A','B','C','D'},'YTickLabel',{'A','B','C','D'});

saveas(gcf, 'plots/part7_eigenvalue_svd.png');
fprintf('  [Plot saved: plots/part7_eigenvalue_svd.png]\n\n');
end

% ------------------------------------------------------------------
function [lambda, v, iters] = power_iteration(A, max_iter, tol)
    n = size(A,1);
    v = rand(n,1); v = v/norm(v);
    lambda = 0;
    for iters = 1:max_iter
        w      = A * v;
        lambda_new = norm(w);
        v      = w / lambda_new;
        if abs(lambda_new - lambda) < tol
            lambda = lambda_new; return;
        end
        lambda = lambda_new;
    end
end
