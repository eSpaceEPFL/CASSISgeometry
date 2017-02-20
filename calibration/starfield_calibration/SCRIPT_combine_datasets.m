function SCRIPT_combine_datasets(combined_set_name, sets_names)

%%

%combined_set_name = 'commissioning2_mcc_motor';
%sets_names = {'mcc_motor', 'commissioning_2'};

dataset_path = '/home/tulyakov/Desktop/espace-server';
addpath(genpath('../libraries'));

%%

nb_sets = length(sets_names);
fprintf('Combining datasets\n');

% read folders structure
comb_set = DATASET_starfields(dataset_path, combined_set_name);

for nset = 1:nb_sets 
        
    fprintf('Dataset %s\n', sets_names{nset});
    
    % combine exposures summary
    cur_set = DATASET_starfields(dataset_path, sets_names{nset});
    
    if nset == 1
        inlierStarSummary = readtable(cur_set.inlierStarSummary);
        expSummary = readtable(cur_set.exposuresSummary);
    else
        inlierStarSummary = [inlierStarSummary; readtable(cur_set.inlierStarSummary)];
        expSummary = [expSummary; readtable(cur_set.exposuresSummary)];
    end
    
end

writetable(expSummary, comb_set.exposuresSummary); 
writetable(inlierStarSummary, comb_set.inlierStarSummary); 





end
