function dist = rational_model_image_side_error(param, xy, chi6D_ij)

npoints = size(xy,1);
[Arow1, Arow2, Arow3] = deal(param(1:6)', param(7:12)', param(13:end)');

xyz_predicted = chi6D_ij*[Arow1;Arow2; Arow3]';
xy_predicted(:,1) = xyz_predicted(:,1)./xyz_predicted(:,3);
xy_predicted(:,2) = xyz_predicted(:,2)./xyz_predicted(:,3);
dist = (xy_predicted - xy);
dist = dist(:);

end