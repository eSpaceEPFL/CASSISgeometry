function [x, y, i, j] = simulate_distortion_field(udist_function, params, image_size, pixelSize)
% Function makes grid of distorted coordinates (i, j) and undistort these coordinates (x, y)
% using undistortion function fhandle and parameters param

n = image_size / 21;
[i, j] = meshgrid(0:n(2):image_size(2),0:n(1):image_size(1));

[ij_fp(:,1), ij_fp(:,2)] = cassis_detector2focalplane(i(:), j(:), image_size(2), image_size(1), pixelSize);

xy_fp = udist_function(params, ij_fp);
 
[xy(:,1), xy(:,2)] = cassis_focalplane2detector(xy_fp(:,1), xy_fp(:,2), image_size(2), image_size(1), pixelSize);

[x, y] = deal(xy(:,1), xy(:,2));
x = reshape(x, size(i));
y = reshape(y, size(i));

end

