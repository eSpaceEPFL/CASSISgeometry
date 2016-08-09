function [points_6D] = lift2D_to_6D(points_2D)
%[points_6D] = lift2D_to_6D(points_2D) Lifts 2D coordinates input to 6D space
%points_2D is npoint x 2 matrix, each row is inhomogenious coordinates
%points_6D is npoint x 6, each row is lifted coordinates\
npoints = size(points_2D,1);
[x, y] = deal(points_2D(:,1), points_2D(:,2));
points_6D = [x.^2 x.*y y.^2 x y ones(npoints,1)];
end

