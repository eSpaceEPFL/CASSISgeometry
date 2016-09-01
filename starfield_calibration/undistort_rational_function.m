function ideal = undistort_rational_function(param, real)
A = [param(1:6)'; param(7:12)'; param(13:18)'];
points_6D = lift2D_to_6D(real);
denom = points_6D*A(3,:)';
ideal(:,1) = (points_6D*A(1,:)')./ denom;
ideal(:,2) = (points_6D*A(2,:)')./ denom;
end

