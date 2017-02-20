function SCRIPT_init_lensDistortion(dataset_name)

 %%

dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));

%%
fprintf('Initializing lens distortion\n');

% read folders structure
set = DATASET_starfields(dataset_path, dataset_name);

%%
A = [0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1]; % no distortion
lensDistortion0 = table(A);
writetable(lensDistortion0, set.lensDistortion0);  

end

