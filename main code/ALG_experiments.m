%% Code to Generate Synthetic Data for Experiments %%

clear; clc; close all;
addpath(genpath(pwd));
addpath('../tproduct toolbox 2.0 (transform)/')
%warning('off','all')

% Define parameters to generate syntehtic data (see hyperparameters.txt)

l = 5; p = 4; n = 10; m = 25;  
tdims = [l,p,n,m];              
 
num_trials = 150;
num_its = 2000;

% Specify model
alg = "QTRK"; % "QTRK" or "mQTRK"

% Corruptions magnitude distribution
corr_option = "large"; % "large" or "small

% Replicate experiments in the paper:
if alg == "QTRK"
    beta_array = [0.025,0.075,0.1]; 
    betarow_array = [0.2,0.4,0.8];
    q_array = [1, 1 - beta_array];   

elseif alg == "mQTRK"
    beta_array = [0.025,0.05,0.075];
    betarow_array = [0.2,0.4,0.8,1];
    q_array = [1, 1 - beta_array, 0.90];

end

if corr_option == "large"
    cor_size = [100,20];

elseif corr_option == "small"
    cor_size = [10,5];
    
end


ALG_plots(alg, tdims, beta_array, betarow_array, q_array, num_trials, num_its, cor_size, corr_option)

