%% Code for QTRK and mQTRK Circular Deblurring Experiments using MRI Data %%

clear; clc; close all;
addpath(genpath(pwd));
addpath("../circular deblurring/")
addpath('../tproduct toolbox 2.0 (transform)/')
%warning('off','all')

% Import data
load mri;                               % loads mri video as order-4 tensor
X = squeeze(double(D));                 % removes dimension 1 mode
X = mat2gray(X(:,:,1:12));              % only first 12 frames   

% Hyperparametes
num_its = 2000; % number of iterations
num_corrupt = 15; % number of corruption
q = 0.99; % quantile value
k = 4; % number of corrupted rows

% Corruptions magnitude distribution
mean_corrupt = 3;
deviation_corrupt = 4;

% Gaussian Filter
h = fspecial('gaussian',[5,5],2);

% Run Experiments
deblurring_plots(X, h, num_its, num_corrupt, q, k, mean_corrupt, deviation_corrupt)

