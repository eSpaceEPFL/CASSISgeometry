function SCRIPT_init_extrinsic_spice()

%%

dataset_path = '/home/tulyakov/Desktop/espace-server';
dataset_name = 'mcc_motor';
addpath(genpath('../libraries'));

%%
fprintf('Initializing rotation from SPICE kernels\n');

% read folders structure
set = DATASET_starfields(dataset_path, dataset_name);

% intrinsics
intrinsic0 = readtable(set.intrinsic0);
K0 = f_x0_y0_2K(intrinsic0.f, intrinsic0.x0, intrinsic0.y0, intrinsic0.pixSize);

% read exposures summary
expSummary = readtable(set.exposuresSummary);
nb_exp = height(expSummary);

% initialize spice
cspice_furnsh(set.spice);

% get angles
f = figure;
for nexp = 1:nb_exp

    % convert time 
    t_str_cassis = expSummary.t_list_(nexp);
    t = cassis_time2num(t_str_cassis);
    time_str_spice = datestr(t,0)
    time{nexp} = t_str_cassis{1};
    time_ET = cspice_str2et(time_str_spice); % time in seconds from J2000
    
    % extract rotational matrices from SPICE kernel
    R_spice = cspice_pxform('J2000', 'TGO_CASSIS_FSA', time_ET);
    q = quaternion.rotationmatrix( R_spice );
    Q(nexp,:) = q.e;

end

time = time';
extrinsic0 = table(Q, time);
writetable(extrinsic0, set.extrinsic0); 



