% Given camera intrinsics, extrinsics, and points function estimates rational
% distortion model

clear all; clc;

% input
train_table_fname = 'DATA_train_set_ra_dec_x_y_time.csv';
test_table_fname = 'DATA_test_set_ra_dec_x_y_time.csv';
intrinsics_fname = 'DATA_intrinsics_f_x0_y0.csv'
extrinsics_fname = 'DATA_extrinsics_rotx_roty_rotz_time.csv';

% output
distortion_fname = 'DATA_distortion_a11_a12_-a36.csv';

train_ra_dec_i_j_time = csvread(train_table_fname,1,0);
test_ra_dec_i_j_time = csvread(test_table_fname,1,0);
f_x0_y0 = csvread(intrinsics_fname,1,0);
rotx_roty_rotz_time = csvread(extrinsics_fname,1,0);

[train_unique_times, ~, train_imageIdx] = unique(train_ra_dec_i_j_time(:,5));
nb_images = length(train_unique_times);

% make more convenient point arrays
% index - catalog
% field - image
train_time = train_ra_dec_i_j_time(:,5);
train_ij_field = train_ra_dec_i_j_time(:,3:4);
[train_XYZ_index(:,1), train_XYZ_index(:,2), train_XYZ_index(:,3)] = ...
raDec2XYZ(deg2rad(train_ra_dec_i_j_time(:,1)), deg2rad(train_ra_dec_i_j_time(:,2)));
train_nb_points = size(train_ij_field, 1);

test_time = test_ra_dec_i_j_time(:,5);
for i = 1:length(test_time)
    test_imageIdx(i) = find(test_time(i) == train_unique_times);
end
test_ij_field = test_ra_dec_i_j_time(:,3:4);
[test_XYZ_index(:,1), test_XYZ_index(:,2), test_XYZ_index(:,3)] = ...
raDec2XYZ(deg2rad(test_ra_dec_i_j_time(:,1)), deg2rad(test_ra_dec_i_j_time(:,2)));
test_nb_points = size(test_ij_field, 1);

% make K and R
R = angles2mat(rotx_roty_rotz_time(:,1), rotx_roty_rotz_time(:,2), rotx_roty_rotz_time(:,3));
K = f_x0_y0_2K(f_x0_y0(1), f_x0_y0(2), f_x0_y0(3));

% compute K*R*XYZ
for npoint = 1:train_nb_points
    train_KRXYZ_index(npoint,:) = (K*R(:,:,train_imageIdx(npoint))*train_XYZ_index(npoint,1:3)')';
end

% compute ideal image coordinates
train_xy_index(:,1) = train_KRXYZ_index(:,1)./train_KRXYZ_index(:,3);
train_xy_index(:,2) = train_KRXYZ_index(:,2)./train_KRXYZ_index(:,3);

% linear estimation of distrotion matrix
train_chi_field = lift2D_to_6D(train_ij_field);
[A0_vec, A0] = estimate_rational_matrix_6_points(train_xy_index, train_chi_field);
