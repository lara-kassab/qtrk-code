function [A] = circ_blurring_mxop(h, sizeX)

%Input: Convolution filter, size of imae being convolved
%output tensor coreesponding to the blurring operation

    [m1,n1] = size(h);
    m = sizeX(1);
    n = sizeX(2);
    h_padded = padarray(h, [m - m1,n-n1], 0, "post");
    
    A = zeros(n,n,m);
    
    for i = 1:m
        c = h_padded(i,:);
        r = [c(1) fliplr(c(end-length(c)+2:end))];
        block = toeplitz(c,r);
        A(1:n,1:n,i) = block;
    end
end





