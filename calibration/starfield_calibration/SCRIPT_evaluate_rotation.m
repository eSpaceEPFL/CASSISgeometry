function SCRIPT_evaluate_rotation()

 
%%
% *Description* :

% Here we evaluate precision of rotation measurment device on board of
% CaSSIS. Our strategy is to compare rotation matrix encoded in CaSSIS
% SPICE kernels with our independent estimation of this matrix.

% We will evaluate precision of rotation matrix in terms of induced reprojection 
% pixel error and in terms of euler angle d/HDD1/Data/CASSIS/2015_06_23_CASSIS_STARFIELD/casssoft/SPICEistance between.  

% We will also search for cosistent bias error between rotation matrix predicted
% by SPICE kernel and estimated rotation matrix.

% Read estimated extrinsics, intrinsics and lens distortion

%% 
% *Include all libraries*

addpath(genpath('mice')) 
addpath(genpath('quaternions')) 

%%
% *Input* :

intrinsics_fname = 'work/DATA_intrinsics.csv'
extrinsics_fname = 'work/DATA_extrinsics.csv';
distortion_fname = 'work/DATA_distortion.csv';
spicekern_fname  = '/HDD1/Data/CASSIS/2016_09_20_CASSIS_STARFIELD/spice/meta.tm';

% * Output* :
orientation_fname = 'work/DATA_rotationErr.csv'

%%
% *Read input data*

intrinsics = table2struct(readtable(intrinsics_fname));
extrinsics = table2struct(readtable(extrinsics_fname));
nb_time = length(extrinsics)
for ntime = 1:nb_time
    orientation(ntime).time = extrinsics(ntime).time;
    time(ntime) = cassis_time2num(extrinsics(ntime).time);
    angles_estim(ntime,:) = deg2rad([extrinsics(ntime).alpha_x extrinsics(ntime).alpha_y extrinsics(ntime).alpha_z]);
end

cspice_furnsh(spicekern_fname);
 
%%
% * Experiments * 

% convert time 
time_str = datestr(time,0)
time_ET = cspice_str2et(time_str); % time in seconds from J2000

% extract rotational matrices from SPICE kernel
R_spice = cspice_pxform('J2000', 'TGO_CASSIS_FSA', time_ET);

% compute euler angles
[ angles_spice(:,1), angles_spice(:,2), angles_spice(:,3) ] =  mat2angles(R_spice);

% compute estimated rotaion matrix
R_estim =  angles2mat(angles_estim(:,1), angles_estim(:,2), angles_estim(:,3));

orientation(1).rotation = 0;
orientation(2).rotation = 0;
orientation(3).rotation = 0;
orientation(4).rotation = 0.2;
orientation(5).rotation = 0.2;
orientation(6).rotation = 0.2;
orientation(7).rotation = 180;
orientation(8).rotation = 180;
orientation(9).rotation = 180;
orientation(10).rotation = 0;
orientation(11).rotation = 0;
orientation(12).rotation = 0;

% compute angular error
for nrot = 1:size(R_estim,3)
    dR(:,:,nrot) =  R_spice(:,:,nrot)*R_estim(:,:,nrot)'
    orientation(nrot).angle_err0 = round(rad2deg(norm(rodrigues(dR(:,:,nrot)))),4); % arcmin
end

%% Find rotation matrix that compensate systematic error
fun = @(sol) cost(sol, R_spice, R_estim); % cost function is average image side residual
x0 = [0 0 0]';
x = fmincon(fun,x0,[],[]);

% test
err0 = cost(x0, R_spice, R_estim)
err = cost(x, R_spice, R_estim)

% compute angular error
R = angles2mat(x(1), x(2), x(3));
for nrot = 1:size(R_estim,3)
    dR(:,:,nrot) =  (R*R_spice(:,:,nrot))*R_estim(:,:,nrot)';
    orientation(nrot).angle_err = round(rad2deg(norm(rodrigues(dR(:,:,nrot)))),4); % arcmin
end



orientation = struct2table(orientation);
writetable(orientation, orientation_fname); 


plot([orientation.angle_err])

% unload kernels
cspice_kclear

end

function err = cost(sol, R1, R2)
    R = angles2mat(sol(1), sol(2), sol(3));
    err = 0;
    for i = 1:size(R1,3)
        err = err + norm(eye(3,3)-(R*R1(:,:,i))*R2(:,:,i)');
        %err = err + rad2deg(norm(rodrigues(R1(:,:,i)*R2(:,:,i)')));
    end
end

