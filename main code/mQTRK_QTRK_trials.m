function [errs_matrix1, errs_matrix2] = mQTRK_QTRK_trials(tdims, num_corrupt, q, k, cor_size, num_trials, num_its)


%% PARAMETERS
% tdims (list): list of dimensions [l,p,n,m] where
% the unknown tensor has shape(l,p,n),
% the left-hand measurement tensor A has shape (m,l,n),
% the right-hand measurement tensor B has shape (m,p,n)

% num_corrupt (integer): actual number of corruptions

% q (0<q<1): quantile value

% k (integer): number of corrupted rows in B that we restrict to (0 < k <= m)

% cor_size(list): [mean_corrupt, deviation_corrupt]

% num_trials (integer>0): number of trials of the experiments for robustness of results

% num_its (integer>0): number of iterations for the iterative algorithm

%% OUTPUTS
% errs_matrix1 (array): num_trials-by-(num_its + 1) rel. errors for QTRK
% errs_matrix2 (array): num_trials-by-(num_its + 1) rel. errors for mQTRK


% Pull given dimensions
l = tdims(1);
p = tdims(2);
n = tdims(3);
m = tdims(4);


% Pull corruption size distribution
mean_corrupt = cor_size(1);
deviation_corrupt = cor_size(2);

% Initialization QTRK Errors Matrix
errs_matrix1 = zeros(num_trials, num_its+1);

% Initialization mQTRK Errors Matrix
errs_matrix2 = zeros(num_trials, num_its+1);

% Perform trials
for t = 1:num_trials

    %generate tensors
    A = randn(m,l,n);
    X_true = randn(l,p,n);
    B = tprod(A,X_true);
    
    % Random initialization for both algorithms
    X0 = randn(l,p,n); 

    % Generate random corruption values for each trial
    corruption_values = normrnd(mean_corrupt, deviation_corrupt,[num_corrupt, 1]);

    % Generate k random row indices to corrupt
    corrupt_rows = randsample(m, k, false);

    % Distribute num_corrupt corruptions uniformly across the k rows
    for i = 1:num_corrupt
        % Select a random row from the chosen rows
        row_idx = corrupt_rows(randsample(k, 1));

        % Randomly select indices for the other dimensions
        col_idx = randsample(p, 1);
        depth_idx = randsample(n, 1);

        % Apply the corruption value
        B(row_idx, col_idx, depth_idx) = B(row_idx, col_idx, depth_idx) + corruption_values(i);
    end
   
    % Run QTRK
    [~, its1] = QTRK_Algorithm(A,B, X0, num_its, q);

    % Run mQTRK
    [~, its2] = mQTRK_Algorithm(A,B, X0, num_its, q);

    % Record errors for the current trial
    for j = 1:num_its + 1
        est1 = its1{j} - X_true;
        errs_matrix1(t,j) = norm(est1(:))/norm(X_true(:)); % Relative Frobenius error to true solution for QTRK
        est2 = its2{j} - X_true;
        errs_matrix2(t,j) = norm(est2(:))/norm(X_true(:)); % Relative Frobenius error to true solution for mQTRK
    end
end

end