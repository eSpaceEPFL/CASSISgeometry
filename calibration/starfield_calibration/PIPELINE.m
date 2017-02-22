clear all;

diary on
addpath(genpath('../libraries'));
set_names = {'mcc_motor', 'pointing_cassis', 'commissioning_2'};
dataset_path = '/home/tulyakov/Desktop/eSpace-server';

%% prepare matched stars
for n = 1:3
 
     % get folders structure
     set = DATASET_starfields(dataset_path, set_names{n});
    
     % find all images
     SCRIPT_search_folder(set);
     
     % collect images to sequences
     SCRIPT_collect_sequences(set);
     
     % save exposures
     SCRIPT_save_rawExp(set);
     
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
     
     % improve extrinsics for each image individually
     SCRIPT_init_extrinsic_local(set);
     
     % find rotation commands using SPICE
     SCRIPT_find_rotCommand_spice(set);

     % bundle adjustment
     % repeat, delet outliers and repeat again until there are no outliers
     while SCRIPT_bundle_adjustment(set) > 0
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

% init lens distortion mete potential outliers
%SCRIPT_filter_outliers(set);

% init intrinsics using factory specs
SCRIPT_init_intrinsic(set);

% init lens distortion model using no distortion assumption
SCRIPT_init_lensDistortion(set);

% init extrinsics using SPICE
SCRIPT_init_extrinsic_spice(set);

% improve extrinsics for each image individually
SCRIPT_init_extrinsic_local(set);

% find rotation commands using SPICE
SCRIPT_find_rotCommand_spice(set);

% bundle adjustment
% repeat, delet outliers and repeat again until there are no outliers

while SCRIPT_bundle_adjustment(set) > 0
    pause(0.1);
end

% init model using no distortion assumption
SCRIPT_init_lensDistortion(set);

% init extrinsics using SPICE
SCRIPT_init_extrinsic_spice(set);
 
% improve extrinsics for each image individually 
SCRIPT_init_extrinsic_local(set);

% find rotation commands using SPICE
SCRIPT_find_rotCommand_spice(set);

% bundle adjustment
% repeat, delet outliers and repeat again until there are no outliers
while SCRIPT_bundle_adjustment(set) > 0 
    pause(0.1);
end 

% delete potential outliers
SCRIPT_filter_outliers(set);

% init intrinsics using factory specs
SCRIPT_init_intrinsic(set);

% init lens distortion model using no distortion assumption
SCRIPT_init_lensDistortion(set);

% init extrinsics using SPICE
SCRIPT_init_extrinsic_spice(set);

% improve extrinsics for each image individually
SCRIPT_init_extrinsic_local(set);

% find rotation commands using SPICE
SCRIPT_find_rotCommand_spice(set);

% bundle adjustment
% repeat, delet outliers and repeat again until there are no outliers
while SCRIPT_bundle_adjustment(set) > 0
    pause(0.1);
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
 
% improve extrinsics for each image individually 
SCRIPT_init_extrinsic_local(set);

% find rotation commands using SPICE
SCRIPT_find_rotCommand_spice(set);

% bundle adjustment
% repeat, delet outliers and repeat again until there are no outliers
while SCRIPT_bundle_adjustment(set) > 0 
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

% bundle adjustment
% repeat, delet outliers and repeat again until there are no outliers
while SCRIPT_bundle_adjustment(set) > 0 
end

% validate camera model (we use rotation, estimated from images)
err = SCRIPT_validate_model(set, 'camera_model');

% validate initial model 
err = SCRIPT_validate_model(set, 'initial_model');

% validate poining model 
err = SCRIPT_validate_model(set, 'pointing_model');

diary off;