function points_10D = lift2D_to_10D(points_2D)
% Function lifts 2D point to 10D space
% points_2D  - [x(:) y(:)]
% points_10D - [npoints x 10]
[x, y] = deal(points_2D(:,1), points_2D(:,2));
points_10D = [x.^3 x.^2.*y x.*y.^2 y.^3 lift2D_to_6D(points_2D)];
end