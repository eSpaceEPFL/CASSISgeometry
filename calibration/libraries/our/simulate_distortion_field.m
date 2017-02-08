function [x, y, i, j] = simulate_distortion_field(udist_function, params, image_size)
% Function makes grid of distorted coordinates (i, j) and undistort these coordinates (x, y)
% using undistortion function fhandle and parameters param

n = image_size / 21;
[i, j] = meshgrid(0:n(2):image_size(2),0:n(1):image_size(1));

ij_norm = pixel2norm([i(:) j(:)], image_size);

xy_norm = udist_function(params,ij_norm);
 
xy = norm2pixel(xy_norm, image_size);

[x, y] = deal(xy(:,1), xy(:,2));
x = reshape(x, size(i));
y = reshape(y, size(i));

end

