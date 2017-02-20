% prepare stars 
dataset = 'mcc_motor';

SCRIPT_filter_outliers('mcc_motor')
 SCRIPT_filter_outliers('pointing_cassis')
% SCRIPT_combine_datasets('mcc_motor_pointing_cassis', {'mcc_motor','pointing_cassis'})
% 
% % preprocess
% dataset_name = 'mcc_motor_pointing_cassis';
% 
% SCRIPT_init_intrinsic(dataset_name);
% SCRIPT_init_lensDistortion(dataset_name);
% SCRIPT_init_extrinsic_spice(dataset_name);
% SCRIPT_init_extrinsic_local(dataset_name);
% SCRIPT_find_rotCommand_spice(dataset_name )
% while SCRIPT_bundle_adjustment(dataset_name) > 0 
% end
% SCRIPT_solve_distortion(dataset_name)

dataset_name = 'mcc_motor_pointing_cassis';

SCRIPT_solve_sysRotErr(dataset_name)

% validate
dataset_name = 'commissioning_2';
SCRIPT_init_extrinsic_spice(dataset_name);
SCRIPT_init_lensDistortion(dataset_name);
SCRIPT_init_intrinsic(dataset_name);
SCRIPT_find_rotCommand_spice(dataset_name )
copyfile('/home/tulyakov/Desktop/espace-server/CASSIS/tests/mcc_motor_pointing_cassis/OUTPUT/sysRotErr.csv',...
'/home/tulyakov/Desktop/espace-server/CASSIS/cruise/160407_commissioning_2/OUTPUT/sysRotErr.csv')
copyfile('/home/tulyakov/Desktop/espace-server/CASSIS/tests/mcc_motor_pointing_cassis/OUTPUT/lensDistortion.csv',...
'/home/tulyakov/Desktop/espace-server/CASSIS/cruise/160407_commissioning_2/OUTPUT/lensDistortion.csv')
copyfile('/home/tulyakov/Desktop/espace-server/CASSIS/tests/mcc_motor_pointing_cassis/OUTPUT/intrinsic_ba.csv',...
'/home/tulyakov/Desktop/espace-server/CASSIS/cruise/160407_commissioning_2/OUTPUT/intrinsic_ba.csv')

SCRIPT_evaluate_model(dataset_name)