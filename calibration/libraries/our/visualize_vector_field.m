function f= visualize_vector_field(x1, y1, x2, y2)
% visualize_vector_field(ideal, dist) Shows distortion as vector field
% (x1,y1)->(x2,y2) with contour lines
% x1, y1 - is [height x width] output of meshgrid function
% x2, y2 - is vector or matrix
f = figure;%figure('units','normalized','outerposition',[0 0 1 1]);
u = x2(:) - x1(:);  % vector direction from ideal to distorted
v = y2(:) - y1(:);
quiver(x1(:), y1(:), u, v); hold on
contour(x1, y1, reshape(sqrt(u.^2+v.^2 ),size(x1)), [2 4 6 8 10 12], 'ShowText','on')
%xlim([0 image_size(2)]);
%ylim([0 image_size(1)]);

%set(gca, 'XTickLabel','');
%set(gca, 'YTickLabel','');
set(gca, 'YDir', 'reverse');
set(gca,'xaxislocation','top');
grid on;
hold off;

hold off;

end

