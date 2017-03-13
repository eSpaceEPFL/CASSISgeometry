function SCRIPT_init_extrinsic_spice(set)

%%

%dataset_path = '/home/tulyakov/Desktop/espace-server';
%if ~exist('dataset_name','var')
%    dataset_name = 'pointing_cassis';
%end
addpath(genpath('../libraries'));

%%
clc
fprintf('Initializing rotation from SPICE kernels\n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

% intrinsics
%intrinsic0 = readtable(set.intrinsic0);
%K0 = f_x0_y0_2K(intrinsic0.f, intrinsic0.x0, intrinsic0.y0, intrinsic0.pixSize);

% read exposures summary
expSummary = readtable(set.exposuresSummary);
nb_exp = height(expSummary);

% initialize spice
cspice_furnsh(set.spice);

% get angles
f = figure;
for nexp = 1:nb_exp

    fprintf('%s\n', expSummary.exp_time{nexp});
        
    % convert time 
    t_str_cassis = expSummary.exp_time{nexp};
    t = cassis_time2num(t_str_cassis);
    time_str_spice = datestr(t,0);
    time{nexp} = t_str_cassis;
    time_ET = cspice_str2et(time_str_spice); % time in seconds from J2000
    
    % extract rotational matrices from SPICE kernel
    R_fsa_2_j2000 = cspice_pxform('J2000', 'TGO_CASSIS_FSA', time_ET);
    q = quaternion.rotationmatrix( R_fsa_2_j2000 );
    Q_fsa_2_j2000(nexp,:) = q.e;
%     
%     R_fsa_2_cru = cspice_pxform('TGO_CASSIS_CRU', 'TGO_CASSIS_FSA', time_ET);
%     q = quaternion.rotationmatrix( R_fsa_2_cru );
%     Q_fsa_2_cru(nexp,:) = q.e;
%     
%     R_cru_2_j2000 = cspice_pxform('J2000', 'TGO_CASSIS_CRU', time_ET);
%     q = quaternion.rotationmatrix( R_cru_2_j2000 );
%     Q_cru_2_j2000(nexp,:) = q.e;
    
end

time = time';
Q = Q_fsa_2_j2000;
extrinsic0 = table(Q, time);
writetable(extrinsic0, set.extrinsic0_spice); 



