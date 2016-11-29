% Given star matches, camera intrinsics and extrinsics SCRIPT estimates rational
% distortion model.

function SCRIPT_solve_distortion()

clc;
fprintf('Estimating rational lens distortion parameters\n');

%% Input
% initial intrinsics (we assume we know from factory specs)
width = 2048;
height = 2048;
pix_size = 10e-6;
% residual of points that we consider as outliers
outlier_res_th = 0.1; % pix

% =============== INPUT 
train_table_fname= 'work/DATA_train_set_ra_dec_x_y_time.csv';
test_table_fname = 'work/DATA_test_set_ra_dec_x_y_time.csv';
intrinsics_fname = 'work/DATA_intrinsics.csv'
extrinsics_fname = 'work/DATA_extrinsics.csv';

% =============== OUTPUT
distortion_fname = 'work/DATA_distortion.csv';

%% Read and rearange input

image_size = [height width];

train_ra_dec_i_j_time = csvread(train_table_fname,1,0);
test_ra_dec_i_j_time = csvread(test_table_fname,1,0);

intrinsics = readtable(intrinsics_fname);
extrinsics = readtable(extrinsics_fname);
intrinsics = table2struct(intrinsics);
extrinsics = table2struct(extrinsics);

nb_images = length(extrinsics);
for ntime = 1:nb_images
    time(ntime) = cassis_time2num(extrinsics(ntime).time);
end

% make more convenient point arrays
% index - catalog
% field - image
train_time = train_ra_dec_i_j_time(:,5);
for ntime = 1:length(train_time)
     train_imageIdx(ntime) = find(train_time(ntime) == time);
end

train_ij_field = train_ra_dec_i_j_time(:,3:4);
[train_XYZ_index(:,1), train_XYZ_index(:,2), train_XYZ_index(:,3)] = ...
raDec2XYZ(deg2rad(train_ra_dec_i_j_time(:,1)), deg2rad(train_ra_dec_i_j_time(:,2)));
train_nb_points = size(train_ij_field, 1);

test_time = test_ra_dec_i_j_time(:,5);
for ntime = 1:length(test_time)
     test_imageIdx(ntime) = find(test_time(ntime) == time);
end
test_ij_field = test_ra_dec_i_j_time(:,3:4);
[test_XYZ_index(:,1), test_XYZ_index(:,2), test_XYZ_index(:,3)] = ...
raDec2XYZ(deg2rad(test_ra_dec_i_j_time(:,1)), deg2rad(test_ra_dec_i_j_time(:,2)));
test_nb_points = size(test_ij_field, 1);

% make K and R
for i = 1:nb_images 
    R(:,:,i) = angles2mat(deg2rad(extrinsics(i).alpha_x),...
                          deg2rad(extrinsics(i).alpha_y),...
                          deg2rad(extrinsics(i).alpha_z));
end
K = f_x0_y0_2K(intrinsics.focal_length / 1e3 / pix_size, intrinsics.x0, intrinsics.y0);

%% Apply estimated camera model

% compute K*R*XYZ
for npoint = 1:train_nb_points
    train_KRXYZ_index(npoint,:) = (K*R(:,:,train_imageIdx(npoint))*train_XYZ_index(npoint,1:3)')';
end
for npoint = 1:test_nb_points
    test_KRXYZ_index(npoint,:) = (K*R(:,:,test_imageIdx(npoint))*test_XYZ_index(npoint,1:3)')';
end

% compute ideal image coordinates
train_xy_index(:,1) = train_KRXYZ_index(:,1)./train_KRXYZ_index(:,3);
train_xy_index(:,2) = train_KRXYZ_index(:,2)./train_KRXYZ_index(:,3);
test_xy_index(:,1) = test_KRXYZ_index(:,1)./test_KRXYZ_index(:,3);
test_xy_index(:,2) = test_KRXYZ_index(:,2)./test_KRXYZ_index(:,3);
clear train_KRXYZ_index;

% compute initial train residual
train_res0 = sqrt(sum((train_ij_field - train_xy_index).^2,2));
test_res0 = sqrt(sum((test_ij_field - test_xy_index).^2,2));

% compute normalized coordinates
train_xy_norm_index = pixel2norm(train_xy_index, image_size);
train_ij_norm_field = pixel2norm(train_ij_field, image_size);
test_ij_norm_field = pixel2norm(test_ij_field, image_size);

% compute lifted coordinates
train_chi_norm_field = lift2D_to_6D(train_ij_norm_field); 
test_chi_norm_field = lift2D_to_6D(test_ij_norm_field); 


%% Optimize
fun = @(param) huber_attenuation( reshape(rational_model_image_side_error(param/param(end), train_xy_norm_index, train_chi_norm_field), [], 1), outlier_res_th/sum(image_size))
options = optimoptions('lsqnonlin', 'Algorithm', 'levenberg-marquardt', 'Display', 'off');
A0_vec = [0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1];
A0_vec = [A0_vec(1,:)'; A0_vec(2,:)'; A0_vec(3,:)'];
A_vec = lsqnonlin(fun, A0_vec, [], [], options);
A = [A_vec(1:6)'; A_vec(7:12)'; A_vec(13:end)'];   
A = A/A(end);
A_vec = A_vec/A_vec(end);


%% Compute test and training errors 

% compute training error
train_pred_xyz_norm_field = train_chi_norm_field*A';
train_pred_xy_norm_field(:,1) = train_pred_xyz_norm_field(:,1)./train_pred_xyz_norm_field(:,3);
train_pred_xy_norm_field(:,2) = train_pred_xyz_norm_field(:,2)./train_pred_xyz_norm_field(:,3);

train_pred_xy_field = norm2pixel(train_pred_xy_norm_field,image_size);
train_res = sqrt(sum((train_pred_xy_field - train_xy_index).^2,2));

% compute test error
test_pred_xyz_norm_field = test_chi_norm_field*A';
test_pred_xy_norm_field(:,1) = test_pred_xyz_norm_field(:,1)./test_pred_xyz_norm_field(:,3);
test_pred_xy_norm_field(:,2) = test_pred_xyz_norm_field(:,2)./test_pred_xyz_norm_field(:,3);

test_pred_xy_field = norm2pixel(test_pred_xy_norm_field,image_size);
test_res = sqrt(sum((test_pred_xy_field - test_xy_index).^2,2));

%% Save results and visualize
test_err = mean(test_res);
train_err = mean(train_res);
fprintf('Train set size %i [points]\n', train_nb_points);
fprintf('Average training residual before optimization %0.3f [pix]\n', mean(train_res0));
fprintf('Average training residual after optimization %0.3f [pix]\n', train_err);

fprintf('Test set size %i [points]\n', test_nb_points);
fprintf('Average test residual before optimization %0.3f [pix]\n', mean(test_res0));
fprintf('Average test residual after optimization %0.3f [pix]\n', test_err);

% save distortion matrix
for i1 = 1:3
    for i2 = 1:6
        eval(['distortion.a' num2str(i1) num2str(i2) '=round(A(' num2str(i1) ',' num2str(i2) '),4);']);
    end
end
distortion.train_err = round(train_err,2);
distortion.test_err = round(test_err,2);
distortion = struct2table(distortion);
writetable(distortion, distortion_fname)

% show training residuals
figure;
C = train_res;
R = 100*train_res / 10;
scatter(train_ij_field(:,1), train_ij_field(:,2), R, C, 'filled');
caxis([0 10])
colorbar;
axis([0 2048 0 2048]);
set(gca, 'ydir', 'reverse');
set(gca,'xaxislocation','top');
grid on;
hold off;
colorbar;

% show distortion field
figure;
[x, y, i, j] = simulate_distortion_field(@undistort_rational_function, A_vec, image_size);
visualize_vector_field(i, j, x, y);
axis([0 2048 0 2048]);
set(gca, 'ydir', 'reverse');
set(gca,'xaxislocation','top');
grid on;
hold off;

end
