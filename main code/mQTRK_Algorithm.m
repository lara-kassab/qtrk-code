function [X,its] = mQTRK_Algorithm(A,B,X0,T,q)

% Goal: Solve a tensor linear system AX=B using mQTRK
% Inputs: A,B,X0 (initial value for unknown tensor X)
% T = max number of iterations 
% q = quantile level

X = X0; % initialize algorithm 
its = {X}; % store all approximations 

for t = 1:T

    % Compute residual tensor
    E = abs(tprod(A, its{t})-B);
    Q = quantile(E, q, "all"); 

    % Sample a row slice
    i_t = randsample(size(A,1), 1);
    A_slice = A(i_t,:,:);
    B_slice = B(i_t,:,:);

    % Identify corrupted column slices for selected row slice
    cor_j = [];
    for j = 1:size(E,2)
        for k = 1:size(E,3)
            if E(i_t, j, k) > Q
               cor_j(end+1) = j;
               break;
            end
        end       
    end 

    % Compute the projection
    A_slice_t = tran(A_slice);
    A_prod_inv = tinv(tprod(A_slice,A_slice_t));
    resid = tprod(A_slice,X) - B_slice;
    t_proj = tprod(tprod(A_slice_t,A_prod_inv),resid);
    t_proj(:,cor_j,:) = zeros(size(X0, 1),length(cor_j),size(X0, 3));

    % Update Approximation
    X = X - t_proj;
    its{end+1} = X;

end

end
