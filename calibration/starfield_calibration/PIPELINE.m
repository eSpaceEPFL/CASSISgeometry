clear all;

%%
diary('hist')
addpath(genpath('../libraries'));
set_names = {'mcc_motor', 'pointing_cassis', 'commissioning_2'};
dataset_path = '/home/tulyakov/Desktop/espace-server';

%%
%% prepare matched stars
for n = 1:3
 
     % get folders structure
     set = DATASET_starfields(dataset_path, set_names{n});
    
     % find all images
     SCRIPT_search_folder(set);
     
     % collect images to sequences
     SCRIPT_collect_sequences(set);
     
     % save exposures
     prm.adjust_subExp_on = false;
     if strcmp(set_names{n}, 'commissioning_2')
         prm.skip_first_exp = 1; % only 3 exposures in every sequence in commissioning_2
     else
         prm.skip_first_exp = 2;
     end
     SCRIPT_save_rawExp(set, prm);
         
     % denoise exposures
     SCRIPT_denoise(set);
     
     % recognize stars
     SCRIPT_recognize(set);
        
     % collect information about detected stars from all images
     SCRIPT_collect_star(set);
     
     % filter outlier stars
     SCRIPT_filter_outliers(set);
     
     % init intrinsics using factory specs
     SCRIPT_init_intrinsic(set);
     
     % init lens distortion model using no distortion assumption
     SCRIPT_init_lensDistortion(set);
     
     % init extrinsics using SPICE
     SCRIPT_init_extrinsic_spice(set);
          
     % find rotation commands using SPICE
     SCRIPT_find_rotCommand_spice(set);
     
     % improve extrinsics for each image individually
     SCRIPT_init_extrinsic_local(set);
    

     % bundle adjustment
     % repeat, delet outliers and repeat again until there are no outliers
     iter = 1;
     while SCRIPT_bundle_adjustment(set,iter) > 0
         iter = iter + 1;
         pause(0.1);
     end

end


%% use first two datasets to estimate camera parameters
 
% combine datasets
SCRIPT_combine_datasets('mcc_motor_pointing_cassis', {'mcc_motor','pointing_cassis'})
 
% get folders structure
set = DATASET_starfields(dataset_path, 'mcc_motor_pointing_cassis');
 
% init intrinsics using factory specs
SCRIPT_init_intrinsic(set);

% init lens distortion model using no distortion assumption
SCRIPT_init_lensDistortion(set);

% init extrinsics using SPICE
SCRIPT_init_extrinsic_spice(set);

% find rotation commands using SPICE
SCRIPT_find_rotCommand_spice(set);

% improve extrinsics for each image individually 
SCRIPT_init_extrinsic_local(set);


% bundle adjustment
% repeat, delet outliers and repeat again until there are no outliers
 iter = 1;
 while SCRIPT_bundle_adjustment(set,iter) > 0
     iter = iter + 1;
     pause(0.1);
 end

% lens distortion estimation
SCRIPT_solve_distortion(set);

% systematic rotation error estimation
SCRIPT_solve_sysRotErr(set);

% copy parameters
copyfile(set.intrinsic_ba, set.intrinsic_final);
copyfile(set.lensDistortion, set.lensDistortion_final);
copyfile(set.sysRotErr, set.sysRotErr_final);

%% validation

% get folders structure
set = DATASET_starfields(dataset_path, 'commissioning_2');

% validate camera model (we use rotation, estimated from images)
err = SCRIPT_validate_model(set, 'camera_model');

% validate initial model 
err = SCRIPT_validate_model(set, 'initial_model');

% validate poining model 
err = SCRIPT_validate_model(set, 'pointing_model');

diary off;