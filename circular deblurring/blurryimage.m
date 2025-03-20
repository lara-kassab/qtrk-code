function [blurryX] = blurryimage(X,h,sizeX)

%Input: Image X, blurring operator h and the corresponding size of X
%Output: circularly blurred image that is suitably reordered so that it
%matches the convolution operation 

m = sizeX(1);
n = sizeX(2);

blurryX_pad = imfilter(X, h, "circular", "full");

blurryX = blurryX_pad(1:m,1:n);



