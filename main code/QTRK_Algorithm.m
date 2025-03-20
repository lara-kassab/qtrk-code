function [X,its] = QTRK_Algorithm(A,B,X0,T,q) 

% Goal: Solve a tensor linear system AX=B using QTRK
% Inputs: A,B,X0 (initial value for unknown tensor X)
% T = max number of iterations 
% q = quantile level

X = X0; % initialize algorithm 
its = {X}; % store all approximations 
total_rows = 1:size(B,1); % array of row indices

for t = 1:T
    
    % Compute residual tensor
    E = abs(tprod(A, its{t})-B); 
    Q = quantile(E, q, "all");
    
    % Identify uncorrupted rows
    corrupted_rows = [];
    for i = 1:size(B, 1)
        if any(E(i, :, :) > Q, 'all')
            corrupted_rows(end + 1) = i;
        end
    end
    uncorrupted_rows = setdiff(total_rows, corrupted_rows);

    % Check for uncorrupted rows
    if isempty(uncorrupted_rows)
        %disp("Warning: Stopped early at iteration: " + t);
        for h = length(its)+1:T+1
            its{h} = X;
        end
        return; 
    end
  
    % Sample row slice from uncorrupted ones
    i_t = randsample(uncorrupted_rows, 1);
    A_slice = A(i_t,:,:);
    B_slice = B(i_t,:,:);

    % Compute the projection
    A_slice_t = tran(A_slice);
    A_prod_inv = tinv(tprod(A_slice,A_slice_t));
    resid = tprod(A_slice,X) - B_slice;
    t_proj = tprod(tprod(A_slice_t,A_prod_inv),resid);
    
    % Update Approximation
    X = X - t_proj;
    its{end+1} = X;

end

end