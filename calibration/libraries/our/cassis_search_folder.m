function [seq_list, t_list_, exp_list, subexp_list, fname_list] = cassis_search_folder(path)
    
    % find all subexposures in the folder 
    [t_list, exp_list, subexp_list, fname_list] = cassis_find_subexp(path);
    
    for i = 1:length(t_list)
        t_list_{i} = cassis_num2time(t_list(i));
    end
    
    % recognize sequences 
    seq_list = cassis_recognize_seq(t_list, exp_list);
    
    seq_list = seq_list';           % zero based    
    t_list_ = t_list_';
    exp_list = exp_list';           % zero based
    subexp_list = subexp_list';     % zero based
    fname_list = fname_list';       
end
