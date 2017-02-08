function SCRIPT_search_folder()

    %% params and dependencies
    dataset_path = '/home/tulyakov/Desktop/espace-server/CASSIS';
    dataset_name = 'stellar_cal_orbit09'; 

    addpath(genpath('../libraries'));

    %%
    % read dataset 
    set = DATASET_starfields(dataset_path, dataset_name);

    % search folder and save everything
    [seq_list, t_list_, exp_list, subexp_list, fname_list] = cassis_search_folder(set.level0);
    folderContent = table(seq_list, t_list_, exp_list, subexp_list, fname_list);
    writetable(folderContent, set.folderContent); 

end
