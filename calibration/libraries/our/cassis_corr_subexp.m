function [subExp, mask] = cassis_corr_subexp(subExp, sensPos, A_dist)

mask = true(size(subExp));
image_size = [2048 2048];

[x_subExp, y_subExp] = meshgrid(1:size(subExp,2), 1:size(subExp,1));
[x0_sensor, y0_sensor] = deal(sensPos(1), sensPos(2));

% subexposure-2-sensor coordinates
[x_sensor, y_sensor] = cassis_subexp2sensor(x_subExp, y_subExp, x0_sensor, y0_sensor);

% sensor-2-frontal focal plane coordinates
[x_front, y_front] = cassis_sensor2virtual(x_sensor, y_sensor, image_size(1));

% normalize
xx = [x_front(:) y_front(:)];
xx_norm = pixel2norm(xx, image_size);
chi = lift2D_to_6D(xx_norm);

% distort
ij_norm = chi*A_dist';
ij_norm(:,1) = ij_norm(:,1)./ij_norm(:,3);
ij_norm(:,2) = ij_norm(:,2)./ij_norm(:,3);
ij_norm = ij_norm(:,[1 2]);

% denormalize
ij = norm2pixel(ij_norm, image_size);

% frontal focal plane coordinates-2-sensor
[i_front, j_front] = deal(ij(:,1), ij(:,2));
i_front = reshape(i_front, size(x_front));
j_front = reshape(j_front, size(x_front));

[i_sensor, j_sensor] = cassis_virtual2sensor(i_front, j_front, image_size(1));

% sensor-2-subexposure
[i_subExp, j_subExp] = cassis_sensor2subexp(i_sensor, j_sensor,  x0_sensor, y0_sensor);

% interpolate
subExp = interp2(x_subExp, y_subExp, subExp, i_subExp, j_subExp);
mask(:,1:5) = false;
mask(:,end-4:end) = false;
mask(1:5,:) = false;
mask(end-4:end,:) = false;
subExp(~mask) = 0;

end