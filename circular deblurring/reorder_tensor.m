function [X_reorder] = reorder_tensor(X, sizeX)

    m = sizeX(1);
    n = sizeX(2);
    p = sizeX(3);
    X_reorder = zeros(n,p,m);
    
    X_unfold = zeros(m*n,p);
    for i = 1:p
        X_unfold(1:m*n,i) = reshape(X(:,:,i),[],1);
    end
    
    startpt = 1;
    endpt = n;
    
    for i=1:m
        X_reorder(1:n,1:p,i) = X_unfold(startpt:endpt,1:p);
        startpt = startpt+n;
        endpt = endpt+n;
    end
end