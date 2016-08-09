% Given table of matches stars script solve for camera parameters.

clear all; clc;

train_table_fname = 'train_ra_dec_x_y_time.csv';
test_table_fname = 'test_ra_dec_x_y_time.csv';

train_ra_dec_x_y_time = csvread(train_table_fname);
test_ra_dec_x_y_time = csvread(test_table_fname);

[train_unique_times, ~, train_imageIdx] = unique(train_ra_dec_x_y_time(:,5));
nb_images = length(train_unique_times);

% make more convenient arrays
% index - catalog
% field - image
train_time = train_ra_dec_x_y_time(:,5);
train_xy_field = train_ra_dec_x_y_time(:,3:4);
[train_XYZ_index(:,1), train_XYZ_index(:,2), train_XYZ_index(:,3)] = ...
raDec2XYZ(deg2rad(train_ra_dec_x_y_time(:,1)), deg2rad(train_ra_dec_x_y_time(:,2)));
train_nb_points = size(train_xy_field, 1);

test_time = test_ra_dec_x_y_time(:,5);
for i = 1:length(test_time)
    test_imageIdx(i) = find(test_time(i) == train_unique_times);
end
test_xy_field = test_ra_dec_x_y_time(:,3:4);
[test_XYZ_index(:,1), test_XYZ_index(:,2), test_XYZ_index(:,3)] = ...
raDec2XYZ(deg2rad(test_ra_dec_x_y_time(:,1)), deg2rad(test_ra_dec_x_y_time(:,2)));
test_nb_points = size(test_xy_field, 1);


%% Initial guesses (and boundaries)

% focal length (if you want to optimize fx and fy you can put two numbers)
f0 = [(880e-3) / 10e-6 (880e-3) / 10e-6]; 
f_lb = f0 - (50e-3) / 10e-6; % -/+50 mm focal length    
f_ub = f0 + (50e-3) / 10e-6; 
% principal point
x00 = 2048/2;
x0_lb = x00 - 500; 
x0_ub = x00 + 500; 
y00 = 2048/2;
y0_lb = y00 - 500; 
y0_ub = y00 + 500; 
% euler angles
angles0 = repmat([0; 0; 0],1,nb_images); % don't make assumptions about rotation angle
angles_lb = repmat([-inf; -inf; -inf],1,train_nb_points); 
angles_ub = repmat([inf; inf; inf],1,train_nb_points); 


%% Optimization

fprintf('Optimizing intrinsics and intrinsics:\n');

% set initial solution
sol0   = f_x0_y0_angles_2vec(f0, x00, y00, angles0);
sol_lb = f_x0_y0_angles_2vec(f_lb, x0_lb, y0_lb, angles_lb);
sol_ub = f_x0_y0_angles_2vec(f_ub, x0_ub, y0_ub, angles_ub);
 
fun = @(sol) (cost(sol, train_XYZ_index, train_xy_field, train_imageIdx, nb_images));

options = optimoptions('lsqnonlin', 'Algorithm', 'trust-region-reflective', 'Display', 'iter', 'MaxIter', 10000, 'TolFun',  1e-15, 'MaxFunEvals', 10000, 'TolX', 1e-15);
[sol, ~, train_res] = lsqnonlin(fun, sol0, sol_lb, sol_ub, options);

% retrive solution 
[f, x0, y0, angles] =  vec2_f_x0_y0_angles(sol, nb_images);
K = f_x0_y0_2K(f, x0, y0);

angles
K

fprintf('Train set size %i [points]\n', train_nb_points);
fprintf('Average training residual %0.3f [pix]\n', mean(train_res));

%% Testing

test_res = cost(sol, test_XYZ_index, test_xy_field, test_imageIdx, nb_images);

fprintf('Test set size %i [points]\n', test_nb_points);
fprintf('Average test residual %0.3f [pix]\n', mean(test_res));




