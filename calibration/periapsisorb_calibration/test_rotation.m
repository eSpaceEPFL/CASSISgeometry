%function SCRIPT_save_images(set)

addpath(genpath('../libraries'));

dataset_path = '/home/tulyakov/Desktop/espace-server/';
dataset_name = 'periapsis_orbit09';
set = DATASET_periapsisorb(dataset_path, dataset_name);

cspice_furnsh(set.spice);

% R_err*R_tel2fso
sysRotErr = readtable(set.sysRotErr_final);
Q = [sysRotErr.Q_1 sysRotErr.Q_2 sysRotErr.Q_3 sysRotErr.Q_4]';
q = quaternion(Q);
R_err = RotationMatrix(q);

R_fsa2tel = cspice_pxform('TGO_CASSIS_FSA', 'TGO_CASSIS_TEL', 3434343);
R_tel2fsa = inv(R_fsa2tel)

R_corr = R_err*R_tel2fsa


q = quaternion.rotationmatrix( R_tel2fsa )
angle_tel2fsa  = EulerAngles(q, '213');
rad2deg(angle_tel2fsa)

q = quaternion.rotationmatrix( R_corr )
angle_corr  = EulerAngles(q, '213');
rad2deg(angle_corr)