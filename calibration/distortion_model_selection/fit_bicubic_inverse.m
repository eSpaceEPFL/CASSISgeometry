function B_vec = fit_bicubic_inverse(ij_norm, xy_norm)
        
    % a*x = b
    % a = [chi10   , 0.*chi10]
    %     [0.*chi10  chi10   ]
    % b = [x]
    %     [y]  
    
    npoints = size(ij_norm,1);
    chi10D_ij_norm = lift2D_to_10D(ij_norm);
    
    A = [chi10D_ij_norm,           zeros(npoints,10);
         zeros(npoints,10)               chi10D_ij_norm;];
    B = [xy_norm(:,1);  xy_norm(:,2)];
        
    AA = A'*A;
    BB = A'*B;
    
    B_vec = AA\BB;
       
end

