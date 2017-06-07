function SCRIPT_search_folder(set)

    %% params and dependencies
    %dataset_path = '/home/tulyakov/Desktop/espace-server/';
    %dataset_name = 'pointing_cassis'; 

    addpath(genpath('../libraries'));

    %%
    % read dataset 
    clc
    fprintf('Searching folder for CaSSIS data\n');
    
    % search folder and save everything
    if isfield(set, 'level1') 
        [seq_list, t_list_, exp_list, subexp_list, fname_list] = cassis_search_folder(set.level1);
    else
        [seq_list, t_list_, exp_list, subexp_list, fname_list] = cassis_search_folder(set.level0);
    end
    folderContent = table(seq_list, t_list_, exp_list, subexp_list, fname_list);
    writetable(folderContent, set.folderContent); 

end
