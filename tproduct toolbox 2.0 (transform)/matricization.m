function [matA,matB,matX] = matricization(A,B,X)
    [m1,n1,p1] = size(A);
    [m,l1,p2] = size(B);
    [n,l,p] = size(X);

    if m1 ~= m
        error('The first dimension of A and B do not agree.');
    end

    if n1 ~= n
        error('The first dimension of X and second of A do not agree.');
    end

    if l1 ~= l
        error('The second dimensions of X and B do not agree.');
    end

    if p1 ~= p
        error('The last dimension of A and X do not agree.');
    end

    if p2 ~= p
        error('The last dimension of X and B do not agree.');
    end

    matB = [];
    matX = [];
    for i = 1:p
        matB = [matB; B(:,:,i)];
        matX = [matX; X(:,:,i)];
    end

    matA = bcirc(A);
end