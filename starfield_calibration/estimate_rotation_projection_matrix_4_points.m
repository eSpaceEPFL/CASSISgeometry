function [P_vec, P, res] = estimate_rotation_projection_matrix_4_points(xy, XYZ)
% Compute projective matrix given normalized real-world coordinates XYZ
% and image coordinates. Note that here we that points undergo only rotation
%  for details refer
% [1] Computer Vision A Modern Approach by Forsyth, p45-46
% [2] Multiple View Geometry by Hartley, p181
% XYZ = [X(:) Y(:) Z(:)] real-world coordinates
% xyz = [x(:) y(:)] image coordinates

% [ x ]       [ X ]  
% [ y ] = P * [ Y ]  
% [ 1 ]       [ Z ]
%             
% ==>
% [  0, -1,  y,]   [ Prow1 * [X Y Z 1]' ]
% [  1,  0, -x,] * [ Prow2 * [X Y Z 1]' ] = 0
% [ -y,  x,  0 ]   [ Prow3 * [X Y Z 1]' ]
% ==>
% [  0 * Prow1 * [X Y Z]'- 1 * Prow2 *[X Y Z]' + y * Prow3 * [X Y Z]';]
% [  1 * Prow1 * [X Y Z]'+ 0 * Prow2 *[X Y Z]' - x * Prow3 * [X Y Z]';] = 0
% [ -y * Prow1 * [X Y Z]'+ x * Prow2 *[X Y Z]' + 0 * Prow3 * [X Y Z]']
% ==>
% [  0 * [X Y Z], -1 * [X Y Z],  y * [X Y Z]; ]   [ Prow1'  ]
% [  1 * [X Y Z],  0 * [X Y Z], -x * [X Y Z]; ] * [ Prow2'  ] = 0
% [ -y * [X Y Z],  x * [X Y Z],  0 * [X Y Z]  ]   [ Prow3'  ]
% ==> A*f = 0

% Note, that 
% (1) to we solve equation using svd trick, therefore we need 
% minimum 6 point correspondences. 
% (2) we use feature scaling before forming A matrix as
% suggested in Multiple View Geometry by Richard Hartley (p109)
     
% Example
%  clear all; close all;
%  XYZ = rand_min_max(4,3, -3, 3);
%  XYZ1 = [XYZ];
%  
%  P_true=[ 3.5e2 3.4e2   2.8e2;
%     -1.0e2 2.3e1   4.6e2  ;
%     7.1e-1 -3.5e-1 6.1e-1 ];
%  
%  xy1 = (P_true*XYZ1')';
% xy(:,1) = xy1(:,1)./xy1(:,3);
% xy(:,2) = xy1(:,2)./xy1(:,3);
% 
% P_vec = estimate_rotation_projection_matrix_4_points(xy, XYZ);



npoints = size(xy,1);

[xy_scaled, T_xy] = scale_features([xy ones(npoints,1)]);

% [  0 * chi_6D, -1 * chi_6D,  y * chi_6D; ]   [ Arow1' ]
% [  1 * chi_6D,  0 * chi_6D, -x * chi_6D; ] * [ Arow2  ] = 0
% [ -y * chi_6D,  x * chi_6D,  0 *  chi_6D ]   [ Arow3  ]
A = [  0 * XYZ, -1 * XYZ,  repmat(xy_scaled(:,2),1,3).*XYZ;...
    1 * XYZ,  0 * XYZ, -repmat(xy_scaled(:,1),1,3).*XYZ;...
    -repmat(xy_scaled(:,2),1,3).*XYZ,  repmat(xy_scaled(:,1),1,3).*XYZ,  0 * XYZ];

f = svd_homogeneous_solver(A);
   
P_scaled = [[f(1:3)'; f(4:6)'; f(7:9)'] [0;0;0]];  
              
% descaling
% x = P*X
% inv(Tx)*Tx*x = P*X
% (Tx*x) = ( Tx*P ) * (X)
% P_scaled = Tx*P
% P = inv(Tx)*P_scaled
P = inv(T_xy)*P_scaled;
P_vec = [P(1,:)'; P(2,:)'; P(3,:)'];    


% compute image based residual
tmp = (P(1:3,1:3)*XYZ')';
xy_pred(:,1) = tmp(:,1) ./ tmp(:,3);  
xy_pred(:,2) = tmp(:,2) ./ tmp(:,3);  
res = sqrt(sum((xy_pred - xy).^2,2));

end
