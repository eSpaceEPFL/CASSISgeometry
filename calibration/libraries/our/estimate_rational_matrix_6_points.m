function A_rational = estimate_rational_matrix_6_points(xy_norm, chi6D_ij_norm)
    % Estimate rational transformation A between normalized points coordinate
    % in ideal image xy_norm and converted to 6D normalized points coordinates in
    % distorted image chi6D_ij_norm
    % and image coordinate xy (z assumed 0).
    % xy = [x(:) y(:)]
    % ij = [i(:) j(:)]
    
    % For details refer: A rational function lens distortion model for genereal
    % cameras by David Claus
    % 
    %     [ x ]               
    % H * [ y ] = Atrue * chi_6D(i, j) 
    %     [ 1 ]
    % where chi_6D(i, j) = [i^2 i*j j^2 i j 1]' 
    % ==>
    % [ x ]               
    % [ y ] = inv(H) * Atrue * chi_6D(i, j) =  A * chi_6D(i, j) 
    % [ 1 ]
    % where A = inv(H) * Atrue 
    % ==>
    % [ x ]               
    % [ y ] x A * chi_6D(i, j) = 0
    % [ 1 ]
    % ==> 
    % [  0, -1,  y,]   [ Arow1 * chi_6D ]   
    % [  1,  0, -x,] * [ Arow2 * chi_6D ]  
    % [ -y,  x,  0 ]   [ Arow3 * chi_6D ]   
    % ==>
    % [  0 * Arow1 * chi_6D, -1 * Arow2 *chi_6D,  y * Arow3 * chi_6D;]
    % [  1 * Arow1 * chi_6D,  0 * Arow2 *chi_6D, -x * Arow3 * chi_6D;] = 0
    % [ -y * Arow1 * chi_6D,  x * Arow2 *chi_6D,  0 * Arow3 * chi_6D ]
    % ==>
    % [  0 * chi_6D, -1 * chi_6D,  y * chi_6D; ]   [ Arow1' ]
    % [  1 * chi_6D,  0 * chi_6D, -x * chi_6D; ] * [ Arow2  ] = 0
    % [ -y * chi_6D,  x * chi_6D,  0 *  chi_6D ]   [ Arow3  ] 
    % ==> A*f = 0
    
    % Note, that 
    % (1) to we solve equation using svd trick, therefore we need 
    % minimum 6 point correspondences. 
    % (2) we use feature scaling before forming A matrix as
    % suggested in Multiple View Geometry by Richard Hartley (p109)
     
    % Example
    %     [i, j] = meshgrid(-0.5:0.5:0.5, -0.5:0.5:0.5);
    %     chi6D_ij_norm = lift2D_to_6D([i(:), j(:)]);
    %     
    %     H = [0.98, 0   , 1e-5;...
    %         0   , 1.01, 1e-7;...
    %         0   , 0   , 1];
    %     
    %     Atrue = [0,   0, 0,   1, 0, 0;...
    %         0,   0, 0,   0, 1, 0;...
    %         0.1, 0, 0.1, 0, 0, 1;];
    %     
    %     xy_norm = (inv(H)*Atrue*chi6D_ij_norm')';
    %     xy_norm = xy_norm(:,1:2)./repmat(xy_norm(:,3),1,2);
    %     plot(xy_norm(:,1), xy_norm(:,2), 'r+'); hold on;
    %     plot(i, j, 'b.');
    %     legend('undistorted', 'distorted');
    %     title('Distorted and undistorted points');
    %     clear i j H Atrue;
    %     A = estimate_rational_matrix_6_points(xy_norm, chi6D_ij_norm)
    
    npoints = size(xy_norm,1);
    
    [xy_norm_scaled, Txy] = scale_features([xy_norm ones(npoints,1)]);
    [chi6D_ij_norm_scaled, Tchi6D] = scale_features(chi6D_ij_norm);
    
    % [  0 * chi_6D, -1 * chi_6D,  y * chi_6D; ]   [ Arow1' ]
    % [  1 * chi_6D,  0 * chi_6D, -x * chi_6D; ] * [ Arow2  ] = 0
    % [ -y * chi_6D,  x * chi_6D,  0 *  chi_6D ]   [ Arow3  ] 
    A = [  0 * chi6D_ij_norm_scaled,                   -1 * chi6D_ij_norm_scaled,                  repmat(xy_norm_scaled(:,2),1,6).*chi6D_ij_norm_scaled;...
           1 * chi6D_ij_norm_scaled,                   0 * chi6D_ij_norm_scaled,                  -repmat(xy_norm_scaled(:,1),1,6).*chi6D_ij_norm_scaled;...
          -repmat(xy_norm_scaled(:,2),1,6).*chi6D_ij_norm_scaled  repmat(xy_norm_scaled(:,1),1,6).*chi6D_ij_norm_scaled,  0 * chi6D_ij_norm_scaled];   
    
    f = svd_homogeneous_solver(A);  
   % f = lse_homogeneous_solver(A,18);  
   A_rational_scaled = [f(1:6)'; f(7:12)'; f(13:end)'];  
              
    % descaling
    % X = A*chi6D
    % inv(Tx)*Tx*X = A*inv(Tchi6D)*Tchi6D*chi6D
    % (Tx*X) = ( Tx*A*inv(Tchi6D) ) * (Tchi6D*chi6D)
    % A_scaled = Tx*A*inv(Tchi6D)
    % A = inv(Tx)*A_scaled*Tchi6D
    A_rational = inv(Txy)*A_rational_scaled*Tchi6D;
    A_rational = [A_rational(1,:)'; A_rational(2,:)'; A_rational(3,:)'];    
end
    
