function [stand] = pixel2norm(pixel, image_size)
% standard = pixel2standard(pixel) Convert pixel to standard coordinates
% pixel - [npoints x 2], pixel coordinates 
% image_size - [height width]
stand(:,1) = (pixel(:,1)  - image_size(2)/2)./sum(image_size);
stand(:,2) = (pixel(:,2)  - image_size(1)/2)./sum(image_size);

end

