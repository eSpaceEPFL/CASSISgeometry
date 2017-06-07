function avgErr = SCRIPT_corr2dist()
    
    addpath(genpath('../libraries'));
    image_size = [2048 2048];

    %%
    % read lens rational correction matrix
    A_corr_tab = readtable('lensCorr_final.csv');
    A_corr = [A_corr_tab.A_1 A_corr_tab.A_2 A_corr_tab.A_3 A_corr_tab.A_4 A_corr_tab.A_5 A_corr_tab.A_6];

    % convert to rational distortion matrix
    [A, maxErr] = inverse_rational_model(A_corr, image_size);
    sprintf('Maximum error of inverse rational model is %0.2f', maxErr)
    
    % save 
    A_dist_tab = table(A);
    writetable(A_dist_tab, 'lensDist_final.csv');

end



