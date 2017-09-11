function SCRIPT_init_lensDistortion(set)

 %%

%dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));

%%
fprintf('Initializing lens distortion\n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

%%
A_corr = [0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1]; % no distortion
lensCorrection0 = table(A_corr);
writetable(lensCorrection0, set.lensCorrection0);  

end

