function [matU, matV,matB,matX] = matricization_factorized(U,V,B,X)
    [m,l,p] = size(U);
    [l1, q, p1 ] = size(V);
    [m1,n,p2] = size(B);
    [q1, n1,p3] = size(X);

    if m1 ~= m
        error('The first dimension of U and B do not agree.');
    end

    if n1 ~= n
        error('The second dimension of X and B do not agree.');
    end

    if l1 ~= l
        error('The second dimension of U and first dimension of V do not agree.');
    end

    if q1 ~= q
        error('The second dimension of V and first dimension of X do not agree.');
    end

    if p1 ~= p
        error('The last dimension of U and V do not agree.');
    end

    if p2 ~= p
        error('The last dimension of U and B do not agree.');
    end
    if p3 ~= p
        error('The last dimension of U and X do not agree.');
    end
    if p1 ~= p2
        error('The last dimension of V and B do not agree.');
    end
    if p2 ~= p3
        error('The last dimension of B and X do not agree.');
    end    

    matB = [];
    matX = [];
    for i = 1:p
        matB = [matB; B(:,:,i)];
        matX = [matX; X(:,:,i)];
    end

    matU = bcirc(U);
    matV = bcirc(V);
end