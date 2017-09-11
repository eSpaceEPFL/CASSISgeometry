function avgErr =SCRIPT_validate_model(set, type)


%dataset_path = '/home/tulyakov/Desktop/espace-server';
addpath(genpath('../libraries'));
image_size = [2048 2048];

%%
clc
fprintf('Evaluate camera model\n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

%% read stars 
starSummary = readtable(set.inlierStarSummary);
[XX(:,1), XX(:,2), XX(:,3)] = ...
raDec2XYZ(deg2rad(starSummary.ra), deg2rad(starSummary.dec));    
xx(:,1) = starSummary.x;false
xx(:,2) = starSummary.y; 
nb_points = height(starSummary);

%% read extirinsic
if  strcmp(type, 'pointing_model')
    % read SPICE 
    extrinsic = readtable(set.extrinsic0_spice); 
elseif strcmp(type, 'camera_model') || strcmp(type, 'initial_model')
    % read extrinsic estimated from images
    extrinsic = readtable(set.extrinsic_ba); 
end
Q = [extrinsic.Q_1 extrinsic.Q_2 extrinsic.Q_3 extrinsic.Q_4];
for npoint = 1:nb_points
    idx = find(cassis_time2num(starSummary.time(npoint)) == cassis_time2num(extrinsic.time));
    q(:,npoint) = quaternion(Q(idx,:));
    R(:,:,npoint) = RotationMatrix(q(:,npoint));
end


%% read intrinsics
if strcmp(type, 'initial_model') 
    % read factory model
    intrinsic = readtable(set.intrinsic0);
elseif    strcmp(type, 'pointing_model') || strcmp(type, 'camera_model')
    % read final model 
    intrinsic = readtable(set.intrinsic_final); 
end
x0 = intrinsic.x0;
y0 = intrinsic.y0;
pixSize = intrinsic.pixSize;
f = intrinsic.f;
K = f_x0_y0_2K(f, x0, y0, pixSize);

%% read lens distortion model
if strcmp(type, 'initial_model') 
    % read factory model
    lensCorrection = readtable(set.lensCorrection0);
elseif    strcmp(type, 'pointing_model') || strcmp(type, 'camera_model')
    % read final model 
    lensCorrection = readtable(set.lensCorrection_final);
end
A_corr = [lensCorrection.A_corr_1 lensCorrection.A_corr_2 lensCorrection.A_corr_3 lensCorrection.A_corr_4 lensCorrection.A_corr_5 lensCorrection.A_corr_6];

[xx_norm(:,1), xx_norm(:,2)] = cassis_detector2focalplane(xx(:,1), xx(:,2), image_size(2), image_size(1), pixSize*1000);
chi = lift2D_to_6D(xx_norm); 
xx_corr_norm = chi*A_corr';
xx_corr_norm(:,1) = xx_corr_norm(:,1)./xx_corr_norm(:,3);
xx_corr_norm(:,2) = xx_corr_norm(:,2)./xx_corr_norm(:,3);
xx_corr_norm = xx_corr_norm(:,[1 2]);
[xx_corr(:,1), xx_corr(:,2)] = cassis_focalplane2detector(xx_corr_norm(:,1), xx_corr_norm(:,2), image_size(2), image_size(1), pixSize*1000);

%% read rotation commands
rotCommands = readtable(set.rotCommand);
for npoint = 1:nb_points
    idx = find(cassis_time2num(starSummary.time(npoint)) == cassis_time2num(extrinsic.time));
    angle(npoint) = rotCommands.angle(idx);
end

%% read systematic rotation error
if strcmp(type, 'initial_model') || strcmp(type, 'camera_model')
    % no rotation error
    for npoint = 1:nb_points
       R_sysErr(:,:,npoint) = eye(3);
    end
elseif strcmp(type, 'pointing_model') 
    % read final rotation error model
    sysRotErr = readtable(set.sysRotErr_final);
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


% use only 360+/-5 deg and 180 +/- 5 deg measurments
% valid = abs(angle'-180) < 5 | abs(angle'-360) < 5;
% xx_corr = xx_corr(valid,:);
% XX = XX(valid,:);
% R = R(:,:,valid);
% angle = angle(valid);
% nb_points = nnz(valid);
% R_sysErr = R_sysErr(:,:,valid);

%% compute error
for npoint = 1:nb_points 
    res_err(npoint,:) = stars2image_error( XX(npoint,:), xx_corr(npoint,:),  R_sysErr(:,:,npoint)*R(:,:,npoint), K);
end

err = sqrt(sum(res_err.^2,2));

f = figure('units','normalized','outerposition',[0 0 1 1]);;
C = err;
R = 1000*err / 10;
scatter(xx(:,1), xx(:,2), R, C, 'filled'); hold on
%caxis([0 0])
colorbar;
axis([0 2048 0 2048]);
grid on;
ax = gca;
ax.YDir = 'reverse';
ax.XAxisLocation = 'top'
colorbar;
%hgexport(f, sprintf('validate_%s.png', type),  ...
%     hgexport('factorystyle'), 'Format', 'png'); 

 avgErr = mean(err);

fprintf('Average error for %s is %d \n', type, avgErr);
    
end



