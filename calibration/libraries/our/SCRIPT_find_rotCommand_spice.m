function SCRIPT_find_rotCommand_spice(set )

%%

%dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'commissioning2_mcc_motor';
addpath(genpath('../libraries'));

%%
clc
fprintf('Find rotation command from SPICE kernels\n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

% read extirinsic
%extrinsic = readtable(set.extrinsic_ba);
%nb_exp = height(extrinsic);

% read exposures summary
expSummary = readtable(set.exposuresSummary);
nb_exp = height(expSummary);

% initialize spice
cspice_furnsh(set.spice);

% get angles
%f = figure;
for nexp = 1:nb_exp

    % convert time 
    t_str_cassis = expSummary.exp_time(nexp);
    t = cassis_time2num(t_str_cassis);
    time_str_spice = datestr(t,0)
    time{nexp} = t_str_cassis{1};
    time_ET = cspice_str2et(time_str_spice); % time in seconds from J2000
    
    % extract CaSSIS rotational matrices w.r.t Equatiorial frame SPICE kernel
    R_spice = cspice_pxform('TGO_CASSIS_CRU', 'TGO_CASSIS_TEL', time_ET);
    
    % commanded rotation 
    q = quaternion.rotationmatrix( R_spice );
    Q(nexp,:) = q.e;
    [angle(nexp), axis(nexp,:)] = AngleAxis( q ); % for interpretability

%     % extract corresponding actual rotation
%     timeInd = find(cassis_time2num(extrinsic.time) == t) 
%     Qvec = [extrinsic.Q_1(timeInd) extrinsic.Q_2(timeInd) extrinsic.Q_3(timeInd) extrinsic.Q_4(timeInd)];
%     q = quaternion(Qvec);
%     R_fsa_from_eq = RotationMatrix(q);
%     R_tel_from_fsa = cspice_pxform('TGO_CASSIS_FSA', 'TGO_CASSIS_TEL', time_ET);
%     R_eq_from_cru = cspice_pxform('TGO_CASSIS_CRU', 'J2000', time_ET);
%     R_equ2tel = (R_tel_from_fsa*R_fsa_from_eq*R_eq_from_cru)'; 
%     q = quaternion.rotationmatrix( R_equ2tel )
%     [angle_actual(nexp), axis_actual(nexp,:)] = AngleAxis( q ); % for interpretability
% 
%     
    
end


time = time';
angle = rad2deg(angle');
rotCommand = table(time, angle, Q);
writetable(rotCommand, set.rotCommand ); 

end
% 
% function diff = angle_diff(angle1, angle2)
%     diff = (angle1-angle2);
%     diff = mod(diff, 360);
%     ind_p360 = abs(diff + 360) < abs(diff);
%     ind_m360 = abs(diff - 360) < abs(diff);
%     diff(ind_p360) = diff(ind_p360) + 360;
%     diff(ind_m360) = diff(ind_m360) - 360;
% end


