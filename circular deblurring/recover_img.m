function [Z_rec] = recover_img(Z,sizeX)
    m = sizeX(1);
    n = sizeX(2);
    p = sizeX(3);
    Z_rec = zeros(m,n,p);
    
    Z_unfold = zeros(n*m,p);
    startpt = 1;
    endpt = n;
    for i = 1:m
        Z_unfold(startpt:endpt,1:p) = Z(:,:,i);
        startpt = startpt+n;
        endpt = endpt+n;
    end
    
    for i=1:p
        Z_rec(:,:,i) = reshape(Z_unfold(:,i),m,n);
    end
end
