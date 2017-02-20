% Given table of matched stars and initial extrinsic and intrinsic
% SCRIPT refines extrinsic and intrinsics using multiple images.

function nb_outliers = SCRIPT_bundle_adjustment(set )

 %%

%dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));
zscore_th = 3; 
neighb = 50;

%%
clc
fprintf('Performing bundle adjustment of extrinsic and intrinsic parameters\n');
fprintf('(should run it 2 times)\n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

% read stars 
inlierStarSummary = readtable(set.inlierStarSummary);
nb_points = height(inlierStarSummary);

% read intrinsics
intrinsic0 = readtable(set.intrinsic0);
x0 = intrinsic0.x0;
y0 =intrinsic0.y0;
pixSize = intrinsic0.pixSize;
f = intrinsic0.f;

% read extirinsic
extrinsic0 = readtable(set.extrinsic0_local);
nb_exp = height(extrinsic0);

% fill initial quaternions
Q = [extrinsic0.Q_1 extrinsic0.Q_2 extrinsic0.Q_3 extrinsic0.Q_4];

% set initial solution
sol0 = f_Q_2vec(f, Q);

% make rotation matrix indexing for speed-up
for n = 1:height(inlierStarSummary)
    rotIdx(n) = find(cassis_time2num(inlierStarSummary.time(n)) == cassis_time2num(extrinsic0.time));
end

% prepare points
[XX(:,1), XX(:,2), XX(:,3)] = ...
raDec2XYZ(deg2rad(inlierStarSummary.ra), deg2rad(inlierStarSummary.dec));    
xx(:,1) = inlierStarSummary.x;
xx(:,2) = inlierStarSummary.y; 

% first run
fun = @(sol) clc_res(sol, x0, y0, pixSize, xx, XX, rotIdx, nb_exp);
options = optimoptions('lsqnonlin', 'Algorithm',  'levenberg-marquardt', 'StepTolerance', 1e-10, 'Display', 'Iter',  'MaxIter', 30);
[sol, ~, res] = lsqnonlin(fun, sol0, [], [], options);
res0 = clc_res(sol0, x0, y0, pixSize, xx, XX, rotIdx, nb_exp);
avgErr0 = mean(sqrt(sum(reshape(res0, nb_points, 2).^2,2)));
avgErr = mean(sqrt(sum(reshape(res, nb_points, 2).^2,2)));

fprintf('Average error before BA %d \n', avgErr0);
fprintf('Average error after BA %d \n', avgErr);

% find outliers
err = sqrt(sum(reshape(res, nb_points, 2).^2,2));
mask = filter_outliers(xx, err, neighb, zscore_th);
nb_outliers = nnz(~mask);
weight = [mask'; mask'];

figure;
C = err;
R = 100*err / 10;
scatter(xx(:,1), xx(:,2), R, C, 'filled'); hold on
plot(xx(~mask,1), xx(~mask,2), 'rx'); % mark out outliers
caxis([0 10])
colorbar;
axis([0 2048 0 2048]);
grid on;
ax = gca;
ax.YDir = 'reverse';
ax.XAxisLocation = 'top'
colorbar;

fprintf('%i points were masked out as outliers \n', nb_outliers);

% retrive solution
[f, Q] =  vec2_f_Q(sol, nb_exp);
fprintf('New focal length is  %d \n', f);

% save intrinsics
intrinsic = table(f, x0, y0, pixSize);
writetable(intrinsic, set.intrinsic_ba);  

% save extrinsics
time = extrinsic0.time;
extrinsic = table(Q, time);
writetable(extrinsic, set.extrinsic_ba);  

% save inliers
inlierStarSummary = inlierStarSummary(mask,:);
writetable(inlierStarSummary, set.inlierStarSummary);

end

function err = clc_res(sol, x0, y0, pixSize, xx, XX, rotIdx, nb_times)
    
    nb_points = size(xx,1);
     
    [f, Q] =  vec2_f_Q(sol, nb_times);
    K = f_x0_y0_2K(f, x0, y0, pixSize);

    % precompute rotation matrices for speed
    for ntime = 1:nb_times
        Qcur = quaternion(Q(ntime,:));
        R(:,:,ntime) = RotationMatrix(Qcur);
    end
    
    % compute Euclidian image error
    parfor npoint = 1:nb_points % parallel on all CPUs
        point_err = stars2image_error( XX(npoint,:), xx(npoint,:), R(:,:,rotIdx(npoint)), K);
        err(npoint,:) = point_err;
    end
    
    err = reshape(err,[],1);
end

