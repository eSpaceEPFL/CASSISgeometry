function SCRIPT_evaluate_model(dataset_name)

%%
if ~exist('dataset_name','var')
    dataset_name = 'commissioning_2';
end

default_intrinsics = false;
default_lens = false;
default_extrinsics = false;

dataset_path = '/home/tulyakov/Desktop/espace-server';
addpath(genpath('../libraries'));
image_size = [2048 2048];

%%
clc
fprintf('Evalute camera model\n');

% read folders structure
set = DATASET_starfields(dataset_path, dataset_name);

%% read stars 
starSummary = readtable(set.inlierStarSummary);
[XX(:,1), XX(:,2), XX(:,3)] = ...
raDec2XYZ(deg2rad(starSummary.ra), deg2rad(starSummary.dec));    
xx(:,1) = starSummary.x;false
xx(:,2) = starSummary.y; 
nb_points = height(starSummary);

%% read SPICE extirinsic
extrinsic_SPICE = readtable(set.extrinsic0_spice); 
Q = [extrinsic_SPICE.Q_1 extrinsic_SPICE.Q_2 extrinsic_SPICE.Q_3 extrinsic_SPICE.Q_4];
for npoint = 1:nb_points
    idx = find(cassis_time2num(starSummary.time(npoint)) == cassis_time2num(extrinsic_SPICE.time));
    q(:,npoint) = quaternion(Q(idx,:));
    R(:,:,npoint) = RotationMatrix(q(:,npoint));
end

%% read intrinsics
if default_intrinsics
    intrinsic = readtable(set.intrinsic0);
else
    intrinsic = readtable(set.intrinsic_ba);
end
x0 = intrinsic.x0;
y0 = intrinsic.y0;
pixSize = intrinsic.pixSize;
f = intrinsic.f;
K = f_x0_y0_2K(f, x0, y0, pixSize);

%% read lens distortion model
if default_lens
    lensDistortion = readtable(set.lensDistortion0);
else
    lensDistortion = readtable(set.lensDistortion);
end
A = [lensDistortion.A_1 lensDistortion.A_2 lensDistortion.A_3 lensDistortion.A_4 lensDistortion.A_5 lensDistortion.A_6];

xx_norm = pixel2norm(xx, image_size);
chi = lift2D_to_6D(xx_norm); 
xx_corr_norm = chi*A';
xx_corr_norm(:,1) = xx_corr_norm(:,1)./xx_corr_norm(:,3);
xx_corr_norm(:,2) = xx_corr_norm(:,2)./xx_corr_norm(:,3);
xx_corr = norm2pixel(xx_corr_norm, image_size);

%% read rotation commands
rotCommands = readtable(set.rotCommand);
for npoint = 1:nb_points
    idx = find(cassis_time2num(starSummary.time(npoint)) == cassis_time2num(extrinsic_SPICE.time));
    angle(npoint) = rotCommands.angle(idx);
end

%% read systematic error
if default_extrinsics
    for npoint = 1:nb_points
       R_sysErr(:,:,npoint) = eye(3);
    end
else
    sysRotErr = readtable(set.sysRotErr);
    Q = [sysRotErr.Q_1 sysRotErr.Q_2 sysRotErr.Q_3 sysRotErr.Q_4]';
    angleRef = sysRotErr.angleRef; 
    nb_ref = length(angleRef);
    for nref = 1:nb_ref
       qRef(:,nref) = quaternion( Q(:,nref) );
    end
    for npoint = 1:nb_points
        q_sysErr(:,npoint) = interp_q(angle(npoint), angleRef, qRef);
        R_sysErr(:,:,npoint) = RotationMatrix( q_sysErr(:,npoint) );
    end
end

%% compute error
for npoint = 1:nb_points % parallel on all CPUs
    xy_err(npoint,:) = stars2image_error( XX(npoint,:), xx_corr(npoint,:),  R_sysErr(:,:,npoint)*R(:,:,npoint), K);
end

err = sqrt(sum(xy_err.^2,2));
avgErr = mean(err);

fprintf('Average error is %d \n', avgErr);

plot(angle, err, '.r');
    
    
end



