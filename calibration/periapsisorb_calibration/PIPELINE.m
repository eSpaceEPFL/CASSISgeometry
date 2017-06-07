clear all;
clc;
diary on;

addpath(genpath('../libraries'));

dataset_path = '/home/tulyakov/Desktop/espace-server/';
dataset_name = 'periapsis_orbit09';

set = DATASET_periapsisorb(dataset_path, dataset_name);

cspice_furnsh(set.spice);

%%
SCRIPT_search_folder(set);

%%
SCRIPT_collect_sequences(set);

%% 
SCRIPT_add_cam_param(set);

%% find rotation commands using SPICE
SCRIPT_find_rotCommand_spice(set);


%%
SCRIPT_save_mapProjExp(set);

%%
prm.skip_first_exp = 0;             % how many first exposures to skip
prm.adjust_subExp_on = true;       % adjust intensity of sub exposures
prm.virtualImage_on = true;         % save virtual image
SCRIPT_save_rawExp(set, prm);

%%
prm.skip_first_exp = 0;             % how many first exposures to skip
prm.adjust_subExp_on = true;       % adjust intensity of sub exposures
prm.virtualImage_on = true;         % save virtual image
SCRIPT_save_undistRawExp(set, prm);

% if find_rotCommand_spice_ON 
%     SCRIPT_find_rotCommand_spice(set);
% end

% if init_extrinsic_spice_ON
%     SCRIPT_init_extrinsic_spice(set);
% end

% if add_cam_params_ON
% end
% 
% if register_subExp_ON
%     SCRIPT_register_subExp(set);
% end
% 
% if save_images_ON
%     SCRIPT_save_images(set);
% end