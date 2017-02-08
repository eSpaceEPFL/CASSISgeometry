function SCRIPT_visualize_errors()

%%
dataset_path = '/home/tulyakov/Desktop/espace-server';
dataset_name = 'mcc_motor';
addpath(genpath('../libraries'));

set = DATASET_starfields(dataset_path, dataset_name);
starSummary = readtable(set.baInlierStarSummary);
extrinsic = readtable(set.extrinsic_ba); 
intrinsic = readtable(set.intrinsic_ba);

%%
% stars
[XX(:,1), XX(:,2), XX(:,3)] = ...
raDec2XYZ(deg2rad(starSummary.ra), deg2rad(starSummary.dec));    
xx(:,1) = starSummary.x;
xx(:,2) = starSummary.y; 
nb_points = height(starSummary);

% intrinsics
K = f_x0_y0_2K(intrinsic.f, intrinsic.x0, intrinsic.y0, intrinsic.pixSize);

% extrinsics
nb_exp = height(extrinsic);
Qvec = [extrinsic.Q_1 extrinsic.Q_2 extrinsic.Q_3 extrinsic.Q_4];
Q = quaternion(Qvec);
for n = 1:nb_exp
    R(:,:,n) = RotationMatrix(Q(n));
end
for n = 1:height(starSummary)
    rotIdx(n) = find(cassis_time2num(starSummary.time(n)) == cassis_time2num(extrinsic.time));
end

% compute residual
for n = 1:nb_points
    [xy_err(n,:), xx_pred(n,:)] = stars2image_error( XX(n,:), xx(n,:), R(:,:,rotIdx(n)), K);
end

err = sqrt(sum(xy_err.^2,2));
fprintf('Average error %0.3f [pix]\n', mean(err));

mask = filter_outliers(xx, err, 100, 3);

figure
plot(xx_pred(:,1), xx_pred(:,2), 'r+'); hold on
plot(xx(:,1), xx(:,2), 'bo'); hold on


% display residual errors
figure;
C = err;
R = 100*err / 10;
scatter(xx(:,1), xx(:,2), R, C, 'filled');
caxis([0 10])
colorbar;
axis([0 2048 0 2048]);
set(gca, 'ydir', 'reverse');
set(gca,'xaxislocation','top');
grid on;
hold off;
colorbar;

