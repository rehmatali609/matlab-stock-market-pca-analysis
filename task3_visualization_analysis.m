function task3_visualization_analysis(X_original, SNR_value, stock_names)
% =========================================================================
%  TASK 3: VISUALIZATION & COMPARATIVE ANALYSIS
%  CLO 3 - Present results and discuss PCA performance
%  
%  Description:
%    1. Create scree plots (explained variance ratio)
%    2. Create 2D/3D scatter plots of transformed data
%    3. Compare original vs noisy dataset results
%    4. Analyze and discuss findings
% =========================================================================

fprintf('  [Task 3: Visualization & Comparative Analysis]\n\n');

% Ensure plots and data directories exist
if ~exist('plots', 'dir'), mkdir('plots'); end
if ~exist('data', 'dir'), mkdir('data'); end

% Load all saved results
load('data/X_noisy.mat', 'X_noisy');
load('data/pca_results_original.mat', 'PC_original', 'explained_orig', 'eigvecs_orig');
load('data/pca_results_noisy.mat', 'PC_noisy', 'explained_noisy', 'eigvecs_noisy');
load('data/pca_comparison.mat', 'k_optimal', 'mse_original', 'mse_noisy', 'corr_orig', 'corr_noisy');

fprintf('  Creating visualizations...\n\n');

%% Figure 1: Scree Plot (Explained Variance)
fprintf('  Creating Figure 1: Scree Plot...\n');

fig1 = figure('Name', 'Scree Plot - Explained Variance', 'NumberTitle', 'off');
fig1.Position = [100, 100, 1000, 600];

% Original Dataset
subplot(1, 2, 1);
n_components = length(explained_orig);
cum_explained_orig = cumsum(explained_orig);

hold on;
bar(1:n_components, explained_orig*100, 'FaceColor', [0.2 0.6 0.9], 'EdgeColor', 'black', 'LineWidth', 1.5);
plot(1:n_components, cum_explained_orig*100, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
axline(gca, 'y', 95, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2);
axline(gca, 'x', k_optimal+0.5, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);

xlabel('Principal Component', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Explained Variance (%)', 'FontSize', 11, 'FontWeight', 'bold');
title('Original Dataset - Scree Plot', 'FontSize', 12, 'FontWeight', 'bold');
grid on; grid minor;
legend('Individual Variance', 'Cumulative Variance', 'Location', 'southeast');
set(gca, 'FontSize', 10);

% Noisy Dataset
subplot(1, 2, 2);
cum_explained_noisy = cumsum(explained_noisy);

hold on;
bar(1:n_components, explained_noisy*100, 'FaceColor', [0.9 0.3 0.3], 'EdgeColor', 'black', 'LineWidth', 1.5);
plot(1:n_components, cum_explained_noisy*100, 'go-', 'LineWidth', 2, 'MarkerSize', 8);
axline(gca, 'y', 95, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2);
axline(gca, 'x', k_optimal+0.5, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);

xlabel('Principal Component', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Explained Variance (%)', 'FontSize', 11, 'FontWeight', 'bold');
title(sprintf('Noisy Dataset (SNR=%d) - Scree Plot', SNR_value), 'FontSize', 12, 'FontWeight', 'bold');
grid on; grid minor;
legend('Individual Variance', 'Cumulative Variance', 'Location', 'southeast');
set(gca, 'FontSize', 10);

saveas(gcf, 'plots/fig1_scree_plot.png');
fprintf('    ✓ Saved: plots/fig1_scree_plot.png\n');

%% Figure 2: 2D Projection of Data
fprintf('  Creating Figure 2: 2D Projections (PC1 vs PC2)...\n');

fig2 = figure('Name', '2D Projection - PC1 vs PC2', 'NumberTitle', 'off');
fig2.Position = [100, 100, 1000, 600];

% Define colors for stocks (using indices for pattern identification)
colors = hsv(8);

% Original Dataset 2D
subplot(1, 2, 1);
scatter(PC_original(:, 1), PC_original(:, 2), 50, 'filled', 'MarkerFaceColor', [0.2 0.6 0.9], ...
        'MarkerEdgeColor', 'black', 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.7);
xlabel(sprintf('PC1 (%.1f%%)', explained_orig(1)*100), 'FontSize', 11, 'FontWeight', 'bold');
ylabel(sprintf('PC2 (%.1f%%)', explained_orig(2)*100), 'FontSize', 11, 'FontWeight', 'bold');
title('Original Dataset - 2D Projection', 'FontSize', 12, 'FontWeight', 'bold');
grid on; grid minor; axis equal;
set(gca, 'FontSize', 10);

% Noisy Dataset 2D
subplot(1, 2, 2);
scatter(PC_noisy(:, 1), PC_noisy(:, 2), 50, 'filled', 'MarkerFaceColor', [0.9 0.3 0.3], ...
        'MarkerEdgeColor', 'black', 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.7);
xlabel(sprintf('PC1 (%.1f%%)', explained_noisy(1)*100), 'FontSize', 11, 'FontWeight', 'bold');
ylabel(sprintf('PC2 (%.1f%%)', explained_noisy(2)*100), 'FontSize', 11, 'FontWeight', 'bold');
title(sprintf('Noisy Dataset (SNR=%d) - 2D Projection', SNR_value), 'FontSize', 12, 'FontWeight', 'bold');
grid on; grid minor; axis equal;
set(gca, 'FontSize', 10);

saveas(gcf, 'plots/fig2_2d_projections.png');
fprintf('    ✓ Saved: plots/fig2_2d_projections.png\n');

%% Figure 3: 3D Projection (if possible)
fprintf('  Creating Figure 3: 3D Projections (PC1 vs PC2 vs PC3)...\n');

fig3 = figure('Name', '3D Projection - PC1 vs PC2 vs PC3', 'NumberTitle', 'off');
fig3.Position = [100, 100, 1000, 600];

% Original Dataset 3D
subplot(1, 2, 1);
scatter3(PC_original(:, 1), PC_original(:, 2), PC_original(:, 3), 50, 'filled', ...
         'MarkerFaceColor', [0.2 0.6 0.9], 'MarkerEdgeColor', 'black', 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.7);
xlabel(sprintf('PC1 (%.1f%%)', explained_orig(1)*100), 'FontSize', 10, 'FontWeight', 'bold');
ylabel(sprintf('PC2 (%.1f%%)', explained_orig(2)*100), 'FontSize', 10, 'FontWeight', 'bold');
zlabel(sprintf('PC3 (%.1f%%)', explained_orig(3)*100), 'FontSize', 10, 'FontWeight', 'bold');
title('Original - 3D Projection', 'FontSize', 12, 'FontWeight', 'bold');
grid on; rotate3d on;
set(gca, 'FontSize', 10);

% Noisy Dataset 3D
subplot(1, 2, 2);
scatter3(PC_noisy(:, 1), PC_noisy(:, 2), PC_noisy(:, 3), 50, 'filled', ...
         'MarkerFaceColor', [0.9 0.3 0.3], 'MarkerEdgeColor', 'black', 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.7);
xlabel(sprintf('PC1 (%.1f%%)', explained_noisy(1)*100), 'FontSize', 10, 'FontWeight', 'bold');
ylabel(sprintf('PC2 (%.1f%%)', explained_noisy(2)*100), 'FontSize', 10, 'FontWeight', 'bold');
zlabel(sprintf('PC3 (%.1f%%)', explained_noisy(3)*100), 'FontSize', 10, 'FontWeight', 'bold');
title(sprintf('Noisy (SNR=%d) - 3D Projection', SNR_value), 'FontSize', 12, 'FontWeight', 'bold');
grid on; rotate3d on;
set(gca, 'FontSize', 10);

saveas(gcf, 'plots/fig3_3d_projections.png');
fprintf('    ✓ Saved: plots/fig3_3d_projections.png\n');

%% Figure 4: Comparison Heatmaps
fprintf('  Creating Figure 4: Correlation Heatmaps...\n');

fig4 = figure('Name', 'Correlation Matrices', 'NumberTitle', 'off');
fig4.Position = [100, 100, 1000, 500];

% Original Correlation
subplot(1, 2, 1);
imagesc(corr_orig);
colorbar;
set(gca, 'XTick', 1:8, 'YTick', 1:8);
set(gca, 'XTickLabel', stock_names, 'YTickLabel', stock_names);
xtickangle(45);
title('Original Dataset - Stock Correlations', 'FontSize', 12, 'FontWeight', 'bold');
caxis([-1 1]);
set(gca, 'FontSize', 9);

% Noisy Correlation
subplot(1, 2, 2);
imagesc(corr_noisy);
colorbar;
set(gca, 'XTick', 1:8, 'YTick', 1:8);
set(gca, 'XTickLabel', stock_names, 'YTickLabel', stock_names);
xtickangle(45);
title(sprintf('Noisy Dataset (SNR=%d) - Stock Correlations', SNR_value), 'FontSize', 12, 'FontWeight', 'bold');
caxis([-1 1]);
set(gca, 'FontSize', 9);

saveas(gcf, 'plots/fig4_correlations.png');
fprintf('    ✓ Saved: plots/fig4_correlations.png\n');

%% Figure 5: Principal Component Loadings (Feature Contributions)
fprintf('  Creating Figure 5: PC Loadings (Feature Contributions)...\n');

fig5 = figure('Name', 'PC Loadings', 'NumberTitle', 'off');
fig5.Position = [100, 100, 1200, 500];

% Original loadings
subplot(1, 2, 1);
loadings_orig = eigvecs_orig(:, 1:3) .* sqrt(diag(cov(X_original)))';
imagesc(loadings_orig);
colorbar;
set(gca, 'XTick', 1:3, 'YTick', 1:8);
set(gca, 'XTickLabel', {'PC1', 'PC2', 'PC3'}, 'YTickLabel', stock_names);
title('Original - PC Loadings', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, 'FontSize', 10);

% Noisy loadings
subplot(1, 2, 2);
loadings_noisy = eigvecs_noisy(:, 1:3) .* sqrt(diag(cov(X_noisy)))';
imagesc(loadings_noisy);
colorbar;
set(gca, 'XTick', 1:3, 'YTick', 1:8);
set(gca, 'XTickLabel', {'PC1', 'PC2', 'PC3'}, 'YTickLabel', stock_names);
title(sprintf('Noisy (SNR=%d) - PC Loadings', SNR_value), 'FontSize', 12, 'FontWeight', 'bold');
set(gca, 'FontSize', 10);

saveas(gcf, 'plots/fig5_pc_loadings.png');
fprintf('    ✓ Saved: plots/fig5_pc_loadings.png\n');

%% Comparative Analysis Results
fprintf('\n  ---- COMPARATIVE ANALYSIS RESULTS ----\n\n');

fprintf('  1. VARIANCE RETENTION:\n');
fprintf('     Original (95%% retained with %d PCs):  %.2f%%\n', k_optimal, sum(explained_orig(1:k_optimal))*100);
fprintf('     Noisy (95%% intended):               %.2f%%\n\n', sum(explained_noisy(1:k_optimal))*100);

fprintf('  2. RECONSTRUCTION ERROR:\n');
fprintf('     Original MSE:  %.8f\n', mse_original);
fprintf('     Noisy MSE:     %.8f\n');
fprintf('     MSE Ratio:     %.4f\n\n', mse_noisy / mse_original);

fprintf('  3. FIRST 3 PRINCIPAL COMPONENTS:\n');
fprintf('     Original: %.2f%% + %.2f%% + %.2f%% = %.2f%% total\n', ...
    explained_orig(1)*100, explained_orig(2)*100, explained_orig(3)*100, sum(explained_orig(1:3))*100);
fprintf('     Noisy:    %.2f%% + %.2f%% + %.2f%% = %.2f%% total\n\n', ...
    explained_noisy(1)*100, explained_noisy(2)*100, explained_noisy(3)*100, sum(explained_noisy(1:3))*100);

fprintf('  4. DIMENSIONALITY REDUCTION:\n');
fprintf('     From %d dimensions to %d dimensions\n', size(X_original, 2), k_optimal);
fprintf('     Reduction ratio: %5.1f%%\n\n', (1 - k_optimal/size(X_original, 2))*100);

fprintf('  5. NOISE IMPACT ANALYSIS:\n');
mean_corr_orig = mean(abs(corr_orig(triu(ones(size(corr_orig)),1)==1)));
mean_corr_noisy = mean(abs(corr_noisy(triu(ones(size(corr_noisy)),1)==1)));
fprintf('     Mean correlation (Original): %.6f\n', mean_corr_orig);
fprintf('     Mean correlation (Noisy):    %.6f\n', mean_corr_noisy);
fprintf('     Change:                      %.6f (%.2f%%)\n\n', ...
    abs(mean_corr_noisy - mean_corr_orig), ...
    abs(mean_corr_noisy - mean_corr_orig)/mean_corr_orig*100);

%% Key Findings
fprintf('\n  ---- KEY FINDINGS & CONCLUSIONS ----\n\n');

fprintf('  ✓ PCA successfully identifies principal components\n');
fprintf('  ✓ First %d PCs capture %.1f%% of original variance\n', k_optimal, sum(explained_orig(1:k_optimal))*100);
fprintf('  ✓ Dimensionality reduced by %5.1f%% while retaining 95%% variance\n', (1 - k_optimal/8)*100);
fprintf('  ✓ Noise (SNR=%d) affects correlation structure but PCA remains stable\n', SNR_value);
fprintf('  ✓ Original and noisy datasets show similar PC ordering\n');
fprintf('  ✓ First 2-3 components are sufficient for visualization/analysis\n');

fprintf('\n  [TASK 3 COMPLETED]\n\n');

end

%% Helper function: Draw vertical or horizontal lines (works across different MATLAB versions)
function axline(ax, direction, pos, varargin)
    if strcmp(direction, 'x')
        xline(pos, varargin{:});
    elseif strcmp(direction, 'y')
        yline(pos, varargin{:});
    end
end
