% =========================================================================
%  CE 342 - Computational Methods and Techniques
%  Course End Project (CEP) - Spring 2026
%  GIK Institute of Engineering Sciences & Technology
%  Semester (VI) Project 
%  Topic   : Principal Component Analysis (PCA) on Stock Market Data
%  Group   Members: Rehmat Ali (2023609) & Sajjad Akbar Khan (2023634)
%  Group   : Registration Numbers ending in 609 and 634
%  Instructor: Dr. Muhammad Omer Bin Saeed
%  Lab Instructor: Engr. Ali Husnain
%  TASKS:
%    TASK 1 (CLO 1, 10 Marks): Data preparation + SNR-based noise generation
%    TASK 2 (CLO 2, 60 Marks): PCA implementation & application
%    TASK 3 (CLO 3, 30 Marks): Visualization & comparative analysis
% =========================================================================

clc; clear; close all;

% Create output directories with proper error handling
if ~exist('plots', 'dir')
    mkdir('plots');
end
if ~exist('data', 'dir')
    mkdir('data');
end

% Verify directories were created
if ~exist('plots', 'dir') || ~exist('data', 'dir')
    error('Failed to create required directories: plots/ and data/');
end

fprintf('=============================================================\n');
fprintf(' CE 342 CEP - PCA on Stock Market Data\n');
fprintf('=============================================================\n\n');

%% SNR CALCULATION FROM REGISTRATION NUMBERS
% Registration numbers: 609, 634
% Average: (609 + 634) / 2 = 621.5
% Sum of digits: 6 + 2 + 1 + 5 = 14
SNR_value = 14;
fprintf('SNR Value (calculated from registration numbers): %d\n\n', SNR_value);

%% ---- TASK 1: DATA PREPARATION & NOISE GENERATION ----
fprintf('=============================================================\n');
fprintf(' TASK 1: Data Preparation & Noise Generation (CLO 1)\n');
fprintf('=============================================================\n\n');

[X_original, stock_names, time_days] = task1_data_preparation(SNR_value);

%% ---- TASK 2a: PCA IMPLEMENTATION TEST (SMALL DATASET) ----
fprintf('\n=============================================================\n');
fprintf(' TASK 2a: PCA Implementation & Verification (CLO 2a)\n');
fprintf('=============================================================\n\n');

task2a_pca_implementation();

%% ---- TASK 2b: PCA APPLICATION ON MAIN DATASET ----
fprintf('\n=============================================================\n');
fprintf(' TASK 2b: Apply PCA to Stock Dataset (CLO 2b)\n');
fprintf('=============================================================\n\n');

task2b_apply_pca(X_original, SNR_value, stock_names);

%% ---- TASK 3: VISUALIZATION & COMPARATIVE ANALYSIS ----
fprintf('\n=============================================================\n');
fprintf(' TASK 3: Visualization & Analysis (CLO 3)\n');
fprintf('=============================================================\n\n');

task3_visualization_analysis(X_original, SNR_value, stock_names);

fprintf('\n=============================================================\n');
fprintf(' All CEP Tasks Completed Successfully!\n');
fprintf(' Check /plots folder for visualizations\n');
fprintf('=============================================================\n');
