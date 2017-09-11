function [invA, maxErr] = inverse_rational_model(A, image_size, pixSize)

% This function given rational distortion matrix A returns rational distortion 
% matrix invA that performs inverse transformation. 
   
[i, j] = meshgrid(1:1:image_size(2), 1:1:image_size(1));
ij = [i(:), j(:)];
[ij_fp(:,1), ij_fp(:, 2)] = cassis_detector2focalplane(ij(:,1), ij(:,2), image_size(2), image_size(1), pixSize);
ij_fp_chi = lift2D_to_6D(ij_fp); 

xy_fp = ij_fp_chi*A';
xy_fp(:,1) = xy_fp(:,1)./xy_fp(:,3);
xy_fp(:,2) = xy_fp(:,2)./xy_fp(:,3);

xy_fp_chi = lift2D_to_6D(xy_fp(:,[1 2])); 

invA = estimate_rational_matrix_6_points(ij_fp, xy_fp_chi);
invA = [invA(1:6)'; invA(7:12)'; invA(13:18)'];

ij_fp_pred = xy_fp_chi*invA';
ij_fp_pred(:,1) = ij_fp_pred(:,1)./ij_fp_pred(:,3);
ij_fp_pred(:,2) = ij_fp_pred(:,2)./ij_fp_pred(:,3);
ij_fp_pred = ij_fp_pred(:,[1 2]);

[ij_pred(:,1), ij_pred(:,2)] = cassis_focalplane2detector(ij_fp_pred(:,1), ij_fp_pred(:,2), image_size(2), image_size(1), pixSize);

err = sqrt(sum((ij - ij_pred).^2, 2));
maxErr = max(err);

end