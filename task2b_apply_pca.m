function task2b_apply_pca(X_original, SNR_value, stock_names)
% =========================================================================
%  TASK 2b: APPLY PCA TO STOCK DATASET
%  CLO 2 - Apply PCA algorithm on main and noisy datasets
%  
%  Description:
%    1. Apply PCA to original stock dataset
%    2. Apply PCA to noisy stock dataset (with SNR-based noise)
%    3. Perform dimensionality reduction (n → k dimensions)
%    4. Calculate and evaluate performance metrics
% =========================================================================

fprintf('  [Task 2b: Apply PCA to Stock Dataset]\n\n');

% Load noisy data
load('data/X_noisy.mat', 'X_noisy');

[n_samples, n_features] = size(X_original);
fprintf('  Dataset Information:\n');
fprintf('    Original shape: [%d x %d]\n', n_samples, n_features);
fprintf('    Stock names: ');
fprintf('%s ', stock_names{:});
fprintf('\n\n');

%% Apply PCA to ORIGINAL Dataset
fprintf('  ---- PCA on ORIGINAL Dataset ----\n\n');

[PC_original, eigvals_orig, eigvecs_orig, explained_orig] = apply_pca(X_original);

fprintf('  Eigenvalues:\n');
fprintf('    ');
fprintf('%.6f ', eigvals_orig(1:min(5, end)));
fprintf('\n');

fprintf('\n  Explained Variance Ratio (%):\n');
for i = 1:min(8, length(explained_orig))
    fprintf('    PC%d: %6.2f%%  (Cumulative: %6.2f%%)\n', i, explained_orig(i)*100, sum(explained_orig(1:i))*100);
end

%% Apply PCA to NOISY Dataset
fprintf('\n  ---- PCA on NOISY Dataset (SNR=%d) ----\n\n', SNR_value);

[PC_noisy, eigvals_noisy, eigvecs_noisy, explained_noisy] = apply_pca(X_noisy);

fprintf('  Eigenvalues:\n');
fprintf('    ');
fprintf('%.6f ', eigvals_noisy(1:min(5, end)));
fprintf('\n');

fprintf('\n  Explained Variance Ratio (%):\n');
for i = 1:min(8, length(explained_noisy))
    fprintf('    PC%d: %6.2f%%  (Cumulative: %6.2f%%)\n', i, explained_noisy(i)*100, sum(explained_noisy(1:i))*100);
end

%% Dimensionality Reduction Analysis
fprintf('\n  ---- Dimensionality Reduction Analysis ----\n\n');

% Determine optimal k for different variance thresholds
variance_thresholds = [0.80, 0.90, 0.95];
fprintf('  Optimal number of components for variance retention:\n\n');
fprintf('  Variance | Original | Noisy   | Reduction\n');
fprintf('  Threshold| Dataset  | Dataset | Ratio\n');
fprintf('  %s\n', repmat('-', 1, 50));

for threshold = variance_thresholds
    k_orig = find(cumsum(explained_orig) >= threshold, 1);
    k_noisy = find(cumsum(explained_noisy) >= threshold, 1);
    reduction_orig = (n_features - k_orig) / n_features * 100;
    
    fprintf('  %5.0f%%   | %d        | %d      | %5.1f%%\n', threshold*100, k_orig, k_noisy, reduction_orig);
end

% Default: 95% variance
k_optimal = find(cumsum(explained_orig) >= 0.95, 1);
if isempty(k_optimal), k_optimal = n_features; end

fprintf('\n  Using k = %d components (retains 95%% of variance)\n\n', k_optimal);

% Project onto optimal k components
X_orig_reduced = PC_original(:, 1:k_optimal);
X_noisy_reduced = PC_noisy(:, 1:k_optimal);

fprintf('  Dimensionality reduction:\n');
fprintf('    Original: [%d x %d] → [%d x %d]\n', n_samples, n_features, n_samples, k_optimal);
fprintf('    Noisy:    [%d x %d] → [%d x %d]\n\n', n_samples, n_features, n_samples, k_optimal);

%% Reconstruction Error Analysis
fprintf('  ---- Reconstruction Error ----\n\n');

% Reconstruct data from reduced dimensions
X_orig_reconstructed = X_orig_reduced * eigvecs_orig(:, 1:k_optimal)';
X_noisy_reconstructed = X_noisy_reduced * eigvecs_noisy(:, 1:k_optimal)';

% Calculate MSE
mse_original = mean((X_original - X_orig_reconstructed).^2, 'all');
mse_noisy = mean((X_noisy - X_noisy_reconstructed).^2, 'all');

fprintf('  Mean Squared Error (MSE):\n');
fprintf('    Original dataset: %.8f\n', mse_original);
fprintf('    Noisy dataset:    %.8f\n\n', mse_noisy);

% Information retained
info_retained_orig = 1 - mse_original;
info_retained_noisy = 1 - mse_noisy;
fprintf('  Information retained:\n');
fprintf('    Original dataset: %.2f%%\n', info_retained_orig*100);
fprintf('    Noisy dataset:    %.2f%%\n\n', info_retained_noisy*100);

%% Correlation Analysis
fprintf('  ---- Feature Correlation Analysis ----\n\n');

cov_orig = cov(X_original);
cov_noisy = cov(X_noisy);

fprintf('  Correlation between stocks (Original dataset):\n');
corr_orig = corr(X_original);
fprintf('  Mean absolute correlation: %.6f\n', mean(abs(corr_orig(triu(ones(size(corr_orig)),1)==1))));

fprintf('\n  Correlation between stocks (Noisy dataset):\n');
corr_noisy = corr(X_noisy);
fprintf('  Mean absolute correlation: %.6f\n', mean(abs(corr_noisy(triu(ones(size(corr_noisy)),1)==1))));

fprintf('\n  Impact of noise on correlation: ');
corr_change = abs(mean(abs(corr_noisy(triu(ones(size(corr_noisy)),1)==1))) - ...
                       mean(abs(corr_orig(triu(ones(size(corr_orig)),1)==1))));
fprintf('%.6f\n\n', corr_change);

%% Save Results
fprintf('  Saving PCA results...\n');
if ~exist('data', 'dir'), mkdir('data'); end
save('data/pca_results_original.mat', 'PC_original', 'eigvals_orig', 'eigvecs_orig', 'explained_orig', 'X_orig_reduced');
save('data/pca_results_noisy.mat', 'PC_noisy', 'eigvals_noisy', 'eigvecs_noisy', 'explained_noisy', 'X_noisy_reduced');
save('data/pca_comparison.mat', 'k_optimal', 'mse_original', 'mse_noisy', 'corr_orig', 'corr_noisy');

fprintf('\n  [TASK 2b COMPLETED]\n\n');

end

%% HELPER FUNCTION: Apply PCA to a dataset
function [PC_scores, eigvals, eigvecs, explained_var] = apply_pca(X)
    % Standardize if not already done
    if max(std(X)) > 2 || min(std(X)) < 0.5
        X = (X - mean(X)) ./ std(X);
    end
    
    % Covariance matrix
    C = cov(X);
    
    % Eigendecomposition
    [eigvecs_unsorted, eigvals_unsorted] = eig(C);
    [eigvals, idx] = sort(diag(eigvals_unsorted), 'descend');
    eigvecs = eigvecs_unsorted(:, idx);
    
    % Explained variance
    explained_var = eigvals / sum(eigvals);
    
    % Project data
    PC_scores = X * eigvecs;
end
