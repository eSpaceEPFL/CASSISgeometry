% Given star matches, camera intrinsics and extrinsics SCRIPT estimates rational
% distortion model.

function SCRIPT_solve_sysRotErr(set)


 %%
%dataset_path = '/home/tulyakov/Desktop/espace-server';
%if ~exist('dataset_name','var')
%    dataset_name = 'mcc_motor_pointing_cassis';
%end
addpath(genpath('../libraries'));
image_size = [2048 2048];
single_sysErr_on = false;

%%
clc;
fprintf('Estimate systematic rotation error\n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

% read stars 
starSummary = readtable(set.inlierStarSummary);
nb_points = height(starSummary);

% read commands
rotCommands = readtable(set.rotCommand);

% read lens distortions
lensDistortion = readtable(set.lensDistortion);
A = [lensDistortion.A_1 lensDistortion.A_2 lensDistortion.A_3 lensDistortion.A_4 lensDistortion.A_5 lensDistortion.A_6];

% read intrinsics
intrinsic = readtable(set.intrinsic_ba);
x0 = intrinsic.x0;
y0 = intrinsic.y0;
pixSize = intrinsic.pixSize;
f  = intrinsic.f;
K = f_x0_y0_2K(f, x0, y0, pixSize);

% read extirinsic
extrinsic = readtable(set.extrinsic0_spice);
nb_exp = height(extrinsic);

% prepare points
[XX(:,1), XX(:,2), XX(:,3)] = ...
raDec2XYZ(deg2rad(starSummary.ra), deg2rad(starSummary.dec));    
xx(:,1) = starSummary.x;
xx(:,2) = starSummary.y; 
nb_points = height(starSummary);

% prepare rotation matrices
Q = [extrinsic.Q_1 extrinsic.Q_2 extrinsic.Q_3 extrinsic.Q_4];

% prepare rotation matrix for speed
for n = 1:height(starSummary)
    idx = find(cassis_time2num(starSummary.time(n)) == cassis_time2num(extrinsic.time));
    Qcur = quaternion(Q(idx,:));
    R(:,:,n) = RotationMatrix(Qcur);
    
    idx = find(cassis_time2num(starSummary.time(n)) == cassis_time2num(extrinsic.time));
    angle(n) = rotCommands.angle(idx);
end

% compute normalized coordinates
xx_norm = pixel2norm(xx, image_size);

% compute lifted coordinates
chi = lift2D_to_6D(xx_norm); 

% precomute corrected coordinates
xx_corr_norm = chi*A';
xx_corr_norm(:,1) = xx_corr_norm(:,1)./xx_corr_norm(:,3);
xx_corr_norm(:,2) = xx_corr_norm(:,2)./xx_corr_norm(:,3);

% denormalize 
xx_corr = norm2pixel(xx_corr_norm, image_size);

% initialize solution
clear Q;
if single_sysErr_on
    % single matrix for 180 and 360 CaSSIS rotation
    q   = quaternion.rotationmatrix( eye(3) );
    Q = q.e;
    angleRef = 180;
else
    % 2 matrices
    q(:,1) = quaternion.rotationmatrix( eye(3) );
    q(:,2) = quaternion.rotationmatrix( eye(3) );
    Q(:,1) = q(:,1).e';
    Q(:,2) = q(:,2).e';
    angleRef = [180 360];
end
sol0 = Q_2vec(Q); 

% use only 360+/-5 deg and 180 +/- 5 deg measurments
valid = abs(angle'-360) < 5 | abs(angle'-180) < 5;
xx_corr = xx_corr(valid,:);
XX = XX(valid,:);
R = R(:,:,valid);
angle = angle(valid);
nb_points = nnz(valid);

% solve
fun = @(sol) clc_res(sol, K, xx_corr, XX, R, angle, angleRef );
options = optimoptions('lsqnonlin', 'Algorithm',  'levenberg-marquardt', 'StepTolerance', 1e-6, 'Display', 'Iter',  'MaxIter', 30);
[sol, ~, res] = lsqnonlin(fun, sol0, [], [], options);
res0 = clc_res(sol0, K, xx_corr, XX, R, angle, angleRef );
Err0 = sqrt(sum(reshape(res0, nb_points, 2).^2,2));
Err = sqrt(sum(reshape(res, nb_points, 2).^2,2));
avgErr0 = mean(Err0);
avgErr = mean(Err);
Q = vec2_Q(sol);

fprintf('Average error with SPICE pointing before systematic error correction %d \n', avgErr0);
fprintf('Average error with SPICE pointing after systematic error correction %d \n', avgErr);

if ~single_sysErr_on
    [angle180, ~] = AngleAxis( quaternion( Q(:,1) ) );
    [angle360, ~] = AngleAxis( quaternion( Q(:,2) ) );

    fprintf('For angle %d correction is %d degree \n', 180, 360-rad2deg(angle180));
    fprintf('For angle %d correction is %d degree \n', 360, 360-rad2deg(angle360));
end

% save distortion matrix
Q = Q';
angleRef = angleRef';
sysRotErr = table(Q, angleRef);
writetable(sysRotErr, set.sysRotErr);

% show training residuals
plot(angle, Err, '.b'); hold on;
plot(angle, Err0,'.r');


end


function err = clc_res(sol, K, xx_corr, XX, R, angle, angleRef)
    
    nb_points = size(xx_corr,1);
    Q = vec2_Q(sol);
    nb_ref = size(Q,2);
    
    for n = 1:nb_ref
        qRef(:,n) = quaternion( Q(:,n) );
    end
    
    for n = 1:nb_points
        
       q = interp_q(angle(n), angleRef, qRef);
       R_sysErr(:,:,n) = RotationMatrix( q );
       
    end
    
    % compute Euclidian image error
    parfor npoint = 1:nb_points % parallel on all CPUs
        point_err = stars2image_error( XX(npoint,:), xx_corr(npoint,:),  R_sysErr(:,:,npoint)*R(:,:,npoint), K);
        err(npoint,:) = point_err;
    end
    
    err = reshape(err,[],1);
end