function [pixel] = norm2pixel(norm, image_size)
% standard = pixel2standard(pixel) Convert pixel to standard coordinates
% norm - [npoints x 2], normalized pixel coordinates 
% image_size - [height width]
pixel(:,1) = (norm(:,1)*sum(image_size) + image_size(2)/2);
pixel(:,2) = (norm(:,2)*sum(image_size) + image_size(1)/2);

end

