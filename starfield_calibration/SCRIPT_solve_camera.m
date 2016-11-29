% Given table of matched stars and initial extrinsic and intrinsic
% SCRIPT refines extrinsic and intrinsics using multiple images.

function SCRIPT_solve_camera()

clc;

fprintf('Performing bundle adjustment of extrinsic and intrinsic parameters\n');

%% Input
% initial intrinsics (we assume we know from factory specs)
pix_size = 10e-6;
f_0 = (880e-3) / pix_size;
x0_0 = 2048/2;
y0_0 = 2048/2; % no distortion
outlier_res_th = 10; % pix

% tables with points
train_table_fname = 'work/DATA_train_set_ra_dec_x_y_time.csv';
test_table_fname = 'work/DATA_test_set_ra_dec_x_y_time.csv';
% table with initial init_extrinsics
init_extrinsics_fname = 'work/DATA_init_extrinsics.csv';

% tables with final intrinsic and init_extrinsics
intrinsics_fname = 'work/DATA_intrinsics.csv';
extrinsics_fname = 'work/DATA_extrinsics.csv';

%==========================================================================

%% Read and rearrange input data
% read input point tables
train_ra_dec_x_y_time = csvread(train_table_fname,1,0);
test_ra_dec_x_y_time = csvread(test_table_fname,1,0);

% read initial init_extrinsics
init_extrinsics = readtable(init_extrinsics_fname);
init_extrinsics = table2struct(init_extrinsics);
for ntime = 1:length(init_extrinsics)
    time(ntime) = cassis_time2num(init_extrinsics(ntime).time);
end
nb_images = length(time);

% make more convenient arrays
% index - catalog
% field - image
train_time = train_ra_dec_x_y_time(:,5);
for ntime = 1:length(train_time)
     train_imageIdx(ntime) = find(train_time(ntime) == time);
end

train_xy_field = train_ra_dec_x_y_time(:,3:4);
[train_XYZ_index(:,1), train_XYZ_index(:,2), train_XYZ_index(:,3)] = ...
    raDec2XYZ(deg2rad(train_ra_dec_x_y_time(:,1)), deg2rad(train_ra_dec_x_y_time(:,2)));
train_nb_points = size(train_xy_field, 1);

test_time = test_ra_dec_x_y_time(:,5);
for ntime = 1:length(test_time)
     test_imageIdx(ntime) = find(test_time(ntime) == time);
end
test_xy_field = test_ra_dec_x_y_time(:,3:4);
[test_XYZ_index(:,1), test_XYZ_index(:,2), test_XYZ_index(:,3)] = ...
    raDec2XYZ(deg2rad(test_ra_dec_x_y_time(:,1)), deg2rad(test_ra_dec_x_y_time(:,2)));
test_nb_points = size(test_xy_field, 1);


%% Optimization
% fill initial angles
for ntime = 1:nb_images
    angles_0(1,ntime) = deg2rad(init_extrinsics(ntime).angle_x);
    angles_0(2,ntime) = deg2rad(init_extrinsics(ntime).angle_y);
    angles_0(3,ntime) = deg2rad(init_extrinsics(ntime).angle_z);
end

% fill bounds 
angles_lb = -inf*ones(size(angles_0));
angles_ub = inf*ones(size(angles_0));

% fill bounds for intrinsic parameters
f_lb = f_0 - (50e-3) / 10e-6; % -/+50 mm focal length
f_ub = f_0 + (50e-3) / 10e-6;
x0_lb = x0_0 - 200; 
x0_ub = x0_0 + 200;
y0_lb = y0_0 - 200;
y0_ub = y0_0 + 200;

% set initial solution
sol0   = f_x0_y0_angles_2vec(f_0, x0_0, y0_0, angles_0);
sol_lb = f_x0_y0_angles_2vec(f_lb, x0_lb, y0_lb, angles_lb);
sol_ub = f_x0_y0_angles_2vec(f_ub, x0_ub, y0_ub, angles_ub);

fun = @(sol) huber_attenuation( clc_res(sol, train_XYZ_index, train_xy_field, train_imageIdx, nb_images), outlier_res_th);
options = optimoptions('lsqnonlin', 'Algorithm', 'trust-region-reflective', 'Display', 'off',  'MaxIter', 30);
[sol, ~, train_res] = lsqnonlin(fun, sol0, sol_lb, sol_ub, options);

% retrive solution
[f, x0, y0, angles] =  vec2_f_x0_y0_angles(sol, nb_images);

% compute test and training error
test_err = round(mean(clc_res(sol, test_XYZ_index, test_xy_field, test_imageIdx, nb_images)),2);
train_err = round(mean(train_res),2);

% prepare tables for saving
intrinsics.focal_length = round(f * pix_size * 1000, 1);
intrinsics.x0 = round(x0,1);
intrinsics.y0 = round(y0,1);
intrinsics.train_err = train_err;
intrinsics.test_err = test_err;

angles = round(rad2deg(angles),4);
for nimage = 1:nb_images
    extrinsics(nimage).time = cassis_num2time(time(nimage));
    extrinsics(nimage).alpha_x = angles(1,nimage);
    extrinsics(nimage).alpha_y = angles(2,nimage);
    extrinsics(nimage).alpha_z = angles(3,nimage);
    extrinsics(nimage).train_err = train_err;
    extrinsics(nimage).test_err = test_err;
end
extrinsics = struct2table(extrinsics);
intrinsics = struct2table(intrinsics);

%% Save solution and display statistics
% save extirinsics (rotation)
writetable(extrinsics, extrinsics_fname);

% save camera intrinsics
writetable(intrinsics, intrinsics_fname);

% display training results
fprintf('Train set size %i [points]\n', train_nb_points);
fprintf('Average training residual %0.3f [pix]\n', (train_err));

% display test tesults
fprintf('Test set size %i [points]\n', test_nb_points);
fprintf('Average test residual %0.3f [pix]\n', test_err);

% display residual errors
figure;
C = train_res;
R = 100*train_res / 10;
scatter(train_xy_field(:,1),train_xy_field(:,2), R, C, 'filled');
caxis([0 10])
colorbar;
axis([0 2048 0 2048]);
set(gca, 'ydir', 'reverse');
set(gca,'xaxislocation','top');
grid on;
hold off;
colorbar;

end

function err = clc_res(sol, XYZ_index, xy_field, imageIdx, nb_times)
    
    nb_points = size(XYZ_index,1);
    
   % [f, x0, y0, Q] =  vec2_f_x0_y0_Q(sol, nb_times);
    [f, x0, y0, angles] =  vec2_f_x0_y0_angles(sol, nb_times);
    R = angles2mat(angles(1,:)', angles(2,:)', angles(3,:)');
    
   K = f_x0_y0_2K(f, x0, y0);
    
    err = zeros(nb_points,1);
    for npoint = 1:nb_points
        %qcur = Q(:,imageIdx(npoint));
        %rcur = qGetR(qcur);
        Rcur = R(:,:,imageIdx(npoint));
        point_err = clc_point_res(XYZ_index(npoint,:), xy_field(npoint,:), K,  Rcur);
        err(npoint) = norm(point_err(:));
    end
        
end

% image side residual for single point
function res = clc_point_res(XYZ_index, xy_field, K, R)

    tmp = (K*R*XYZ_index')';
    x_pred(:,1) = tmp(:,1)./tmp(:,3);
    x_pred(:,2) = tmp(:,2)./tmp(:,3);
    res = sqrt(sum((x_pred - xy_field).^2,2));

end

