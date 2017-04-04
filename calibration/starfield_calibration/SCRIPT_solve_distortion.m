% Given star matches, camera intrinsics and extrinsics SCRIPT estimates rational
% distortion model.

function SCRIPT_solve_distortion(set)

%%

%dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));
image_size = [2048 2048];

%%
clc;
fprintf('Estimating rational lens distortion parameters\n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

% read stars 
starSummary = readtable(set.inlierStarSummary);
nb_points = height(starSummary);

% read lens distortions
lensDistortion0 = readtable(set.lensDistortion0);
A0 = [lensDistortion0.A_1 lensDistortion0.A_2 lensDistortion0.A_3 lensDistortion0.A_4 lensDistortion0.A_5 lensDistortion0.A_6];

% read intrinsics
intrinsic = readtable(set.intrinsic_ba);
x0 = intrinsic.x0;
y0 = intrinsic.y0;
pixSize = intrinsic.pixSize;
f  = intrinsic.f;
K = f_x0_y0_2K(f, x0, y0, pixSize);

% read extirinsic
extrinsic = readtable(set.extrinsic_ba);
nb_exp = height(extrinsic);

%% Apply estimated camera model

% prepare points
[XX(:,1), XX(:,2), XX(:,3)] = ...
raDec2XYZ(deg2rad(starSummary.ra), deg2rad(starSummary.dec));    
xx(:,1) = starSummary.x;
xx(:,2) = starSummary.y; 
nb_points = height(starSummary);

% prepare rotation matrices
Qvec = [extrinsic.Q_1 extrinsic.Q_2 extrinsic.Q_3 extrinsic.Q_4];
Q = quaternion(Qvec);
for n = 1:nb_exp
    R(:,:,n) = RotationMatrix(Q(n));
end

% prepare point-rotation matrix indexing for speed
for n = 1:height(starSummary)
    rotIdx(n) = find(cassis_time2num(starSummary.time(n)) == cassis_time2num(extrinsic.time));
end

% map stars to sensor plane
for n = 1:nb_points
    [res(n,:), xx_pred(n,:)] = stars2image_error( XX(n,:), xx(n,:), R(:,:,rotIdx(n)), K);
end

% compute normalized coordinates
xx_norm = pixel2norm(xx, image_size);
xx_pred_norm = pixel2norm(xx_pred, image_size);

% compute lifted coordinates
chi_norm = lift2D_to_6D(xx_norm); 

% solve distortion
fun = @(param) reshape(rational_model_image_side_error(param/param(end), xx_pred_norm, chi_norm), [], 1)
options = optimoptions('lsqnonlin', 'Algorithm', 'levenberg-marquardt', 'Display', 'iter');
sol0 = [A0(1,:)'; A0(2,:)'; A0(3,:)'];
[sol,~,res] = lsqnonlin(fun, sol0, [], [], options);
res0 = reshape(rational_model_image_side_error(sol0/sol0(end), xx_pred_norm, chi_norm), [], 1);
A = [sol(1:6)'; sol(7:12)'; sol(13:end)'];   
A = A/A(end);

err = sqrt(sum(reshape(res*sum(image_size), nb_points, 2).^2,2));
avgErr0 = mean(sqrt(sum(reshape(res0*sum(image_size), nb_points, 2).^2,2)));
avgErr = mean(err);

fprintf('Average error before distortion estimation %d \n', avgErr0);
fprintf('Average error after distortion estimation %d \n', avgErr);

% save un-distortion matrix
lensDistortion = table(A);
writetable(lensDistortion, set.lensDistortion);


% show training residuals
f1 = figure('units','normalized','outerposition',[0 0 1 1]);;
C = err;
R = 100*err / 10;
scatter(xx(:,1), xx(:,2), R, C, 'filled'); hold on
caxis([0 3])
colorbar;
axis([0 2048 0 2048]);
grid on;
ax = gca;
ax.YDir = 'reverse';
ax.XAxisLocation = 'top'
colorbar;
hgexport(f1, set.lensDistortion_residuals_IMG,  ...
     hgexport('factorystyle'), 'Format', 'png'); 

% show distortion field
[x, y, i, j] = simulate_distortion_field(@undistort_rational_function, sol, image_size);
f = visualize_vector_field(i, j, x, y);
axis([0 2048 0 2048]);
hgexport(f, set.lensDistortion_field_IMG,  ...
     hgexport('factorystyle'), 'Format', 'png'); 
% 
% %
% [invA, maxErr] = inverse_rational_model(A, image_size)
% 
% 
% figure;
% [x, y, i, j] = simulate_distortion_field(@undistort_rational_function, [invA(1,:)'; invA(2,:)'; invA(3,:)'], image_size);
% visualize_vector_field(i, j, x, y);
% axis([0 2048 0 2048]);

end
