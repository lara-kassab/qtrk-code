function A_pinv = tpinv(A)
%
% Output: 
%        A_pinv      -   pseudoinverse of tensor A


[n1,n2,~] = size(A);

if n1 <= n2
    A_pinv = tprod(tran(A),tinv(tprod(A,tran(A))));
else
    A_pinv = tprod(tinv(tprod(tran(A),A)),tran(A));
end