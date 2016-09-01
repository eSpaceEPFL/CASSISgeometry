% Given table of 3D and 2D points correspondences, SCRIPT computes initial 
% guesses for extrinsic parameters for every image independently. 
% When optimizing extrinsics we fix intrinsics to camera specs.

function SCRIPT_init_extrinsic()

fprintf('Estimating initial extrinsic parameters\n');
 
%% Input

addpath('quaternions'); 

% initial intrinsics (we assume we know from factory specs)
prm.f_0 = (880e-3) / 10e-6;
prm.x0_0 = 2048/2;
prm.y0_0 = 2048/2; % no distortion
% maximum allowed size of average residual 
% (optimization is repeated until average residual is smaller than this value)
prm.max_res = 8;

% table with dataset
train_table_fname = 'work/DATA_train_set_ra_dec_x_y_time.csv';
test_table_fname = 'work/DATA_test_set_ra_dec_x_y_time.csv';

% table with initial intrinsics
init_intrinsics_fname = 'work/DATA_init_extrinsics.csv';

K0 = f_x0_y0_2K(prm.f_0, prm.x0_0, prm.y0_0);

%% Read and reorganize input

train_ra_dec_x_y_time = csvread(train_table_fname,1,0);
test_ra_dec_x_y_time = csvread(test_table_fname,1,0);

[train_unique_times, ~, ~] = unique(train_ra_dec_x_y_time(:,5));
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
%for i = 1:length(test_time)
%    test_imageIdx(i) = find(test_time(i) == train_unique_times);
%end
test_xy_field = test_ra_dec_x_y_time(:,3:4);
[test_XYZ_index(:,1), test_XYZ_index(:,2), test_XYZ_index(:,3)] = ...
    raDec2XYZ(deg2rad(test_ra_dec_x_y_time(:,1)), deg2rad(test_ra_dec_x_y_time(:,2)));
test_nb_points = size(test_xy_field, 1);

%% Compute initial extrinsics for every image
%fid = fopen(init_intrinsics_fname, 'w');
%fprintf(fid, '%% q1 [], q2 [], q3 [], q4 [], time [days from 0 year]\n');
%fclose(fid);
   
for i =1:nb_images
    
    % get all points that belong to current image
    ind_train = train_time == train_unique_times(i);
    x_train = train_xy_field(ind_train,:);
    X_train =  train_XYZ_index(ind_train,:);
    
    ind_test = test_time == train_unique_times(i);
    x_test = test_xy_field(ind_test,:);
    X_test =  test_XYZ_index(ind_test,:);
    
    % compute rotation using linear algotith
    
    % firstly find rotational homography
    [~, P, ~] = estimate_rotation_projection_matrix_4_points(x_train, X_train);
   
    % now compute rotation matrix assuming that we know intrinsic
    R_not_orth = inv(K0)*P(1:3,1:3);
    
    % now enforce orhtogonality of rotational matrix
    [U,S,V] = svd(R_not_orth);
    R = U*V';
    q0 = qGetQ(R);
    q0 = qNormalize(q0);
    
    % perform nonlinear constrained optimization
    % to find exact rotation matrix
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = [-1; -1; -1; -1];  % since quaternion norm is 1, elements of quaternion is <= 1
    ub = [1; 1; 1; 1];
    
    fun = @(sol) mean(clc_res(X_train, x_train, sol, K0)); % cost function is average image side residual
    train_res = -1;
    while (train_res > prm.max_res)||(train_res == -1)
        % if initial guess is wrong try new random guess
        options = optimset('Display', 'off') ;
        [q(:,i), train_res] = fmincon(fun,q0,A,b,Aeq,beq,lb,ub,@constraint,options);
        if(train_res  > prm.max_res) 
            q0 = qNormalize(rand(4,1));
        end
       
    end
    
    [sol0(1), sol0(2), sol0(3)] = mat2angles(qGetR( q(:,i) ));
     
    fun = @(sol) clc_res_lin(X_train, x_train, sol, K0);
    options = optimoptions('lsqnonlin', 'Algorithm', 'levenberg-marquardt', 'Display', 'off', 'MaxIter', 30);
    [sol, ~, ~] = lsqnonlin(fun, sol0, [], [], options);

    extrinsics(i).time = cassis_num2time(train_unique_times(i)); 
    sol = round(rad2deg(sol),4);
    [extrinsics(i).angle_x, extrinsics(i).angle_y, extrinsics(i).angle_z] = deal(sol(1), sol(2), sol(3));
    
    % compute test set average residual
    extrinsics(i).train_res = round(mean(clc_res(X_train, x_train, q(:,i), K0)),2);
    extrinsics(i).test_res = round(mean(clc_res(X_test, x_test, q(:,i), K0)),2);
    % display training results
    fprintf('Image #%i, avg train residual %0.3f [pix]\n', i, (extrinsics(i).train_res));

    % display test tesults
    fprintf('Image #%i, avg test residual %0.3f [pix]\n', i, (extrinsics(i).test_res));

end


% initial extrinsics
extrinsics = struct2table(extrinsics);
writetable(extrinsics, init_intrinsics_fname);

end



%% Cost function for nonlinear optimization
function res = clc_res_lin(XX,xx,a,K)
    R = angles2mat(a(1),a(2),a(3)) ;
    tmp = (K*R*XX')';
    x_pred(:,1) = tmp(:,1)./tmp(:,3);
    x_pred(:,2) = tmp(:,2)./tmp(:,3);
    res = reshape((x_pred - xx),[],1);
end

%% Cost function for nonlinear optimization
function res = clc_res(XX,xx,Q,K)
    R = qGetR( Q ) ;
    tmp = (K*R*XX')';
    x_pred(:,1) = tmp(:,1)./tmp(:,3);
    x_pred(:,2) = tmp(:,2)./tmp(:,3);
    res = sqrt(sum((x_pred - xx).^2,2));
end

%% Constraint: norm of quanternion should be 1
function [c,ceq] = constraint(q)
    ceq = 1-sum(q.^2);
    c = [];
end