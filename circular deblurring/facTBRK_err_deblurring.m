function [X,res_errs] = facTBRK_err_deblurring(U,V,Y,X_0,T,out_block_size,in_block_size)
    %record number of row slices
    m = size(U,1);
    m_2 = size(V,1);

    %initialize iterate
    X = zeros(size(X_0));
    Z = zeros(size(tprod(V,X_0)));
    res_errs = zeros(T);

    %iterate
    for t = 1:T
        %sample row slice from U to update Z in terms of Y residuals
        mu_t = randsample(m,out_block_size,false);
        U_slice = U(mu_t,:,:);
        Y_slice = Y(mu_t,:,:);

        %calculate necessary transformations of U_slice
        U_slice_t = tran(U_slice);
        U_prod_inv = tinv(tprod(U_slice,U_slice_t));
        resid_y = tprod(U_slice,Z) - Y_slice;

        %RK step 
        Z = Z - tprod(tprod(U_slice_t,U_prod_inv),resid_y);

        %sample row slice from V to update X in terms of Z residuals
        nu_t = randsample(m_2,in_block_size,false);
        V_slice = V(nu_t,:,:);
        Z_slice = Z(nu_t,:,:);


        %calculate necessary transformations of V_slice
        V_slice_t = tran(V_slice);
        V_prod_inv = tinv(tprod(V_slice,V_slice_t));
        resid_z = tprod(V_slice,X) - Z_slice;

        %RK step 
        X = X - tprod(tprod(V_slice_t,V_prod_inv),resid_z);
        res_est = tprod(U,tprod(V,X)) - Y;
        res_errs(t) = norm(res_est(:),"fro")/norm(Y(:),"fro");
    end
end
