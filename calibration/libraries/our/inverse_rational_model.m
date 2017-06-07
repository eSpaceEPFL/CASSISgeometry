function [invA, maxErr] = inverse_rational_model(A, image_size)

% This function given rational distortion matrix A returns rational distortion 
% matrix invA that performs inverse transformation. 
   
[i, j] = meshgrid(1:10:image_size(2), 1:10:image_size(1));
ij = [i(:), j(:)];
ij_norm = pixel2norm(ij, image_size);
ij_chi = lift2D_to_6D(ij_norm); 

xy_norm = ij_chi*A';
xy_norm(:,1) = xy_norm(:,1)./xy_norm(:,3);
xy_norm(:,2) = xy_norm(:,2)./xy_norm(:,3);

xy_chi = lift2D_to_6D(xy_norm(:,[1 2])); 

invA = estimate_rational_matrix_6_points(ij_norm, xy_chi);
invA = [invA(1:6)'; invA(7:12)'; invA(13:18)'];

ij_norm_pedic = xy_chi*invA';
ij_norm_pedic(:,1) = ij_norm_pedic(:,1)./ij_norm_pedic(:,3);
ij_norm_pedic(:,2) = ij_norm_pedic(:,2)./ij_norm_pedic(:,3);
ij_norm_pedic = ij_norm_pedic(:,[1 2]);

err = sqrt(sum((ij - norm2pixel(ij_norm_pedic,image_size)).^2, 2));
maxErr = max(err);

end