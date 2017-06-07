% Scripts takes raw CaSSIS subExp datastripes and saves them as images
% it also saves undistorted datastripes 

%function SCRIPT_save_subExp(set)

%% TO-DO delete
% read folder structure
dataset_path = '/home/tulyakov/Desktop/espace-server/';
set = DATASET_periapsisorb(dataset_path, 'periapsis_orbit09');


%% params and dependencies

addpath(genpath('../libraries'));

%%
clc
fprintf('Saving CaSSIS subExposure images from %s set\n', set.name);

% load distortion matrix
A_dist_raw = readtable('../starfield_calibration/lensDist_final.csv');
A_dist = [A_dist_raw.A_1 A_dist_raw.A_2 A_dist_raw.A_3 A_dist_raw.A_4 A_dist_raw.A_5 A_dist_raw.A_6];

% load folder content summary
folderContent = readtable(set.folderContent);
nb_subExp = height(folderContent);

fprintf('%i subexposures were found\n', nb_subExp);
fprintf('Decoding and saving subexposures:\n');

i = 1;
for nsubExp = 1:nb_subExp
    
    fprintf('Sub-exposure # %i started..\n', nsubExp);
    
    %%
    fname = fullfile(set.level1, folderContent.fname_list{nsubExp});
    [subexp, sensPos] = cassis_read_subexp(fname, 'float=>float');  
    
    %%
    [subexp_corr, mask] = cassis_corr_subexp(subexp, sensPos, A_dist);
    lim = stretchlim(reshape(subexp_corr(mask),[],1));
    subexp_corr(mask) = imadjust(subexp_corr(mask), lim);
    subexp(mask) = imadjust(subexp(mask),lim);
    
    fname = fullfile(set.raw_subexp, [ folderContent.fname_list{nsubExp}(1:end-4) '_corr.png']);
    imwrite(subexp_corr, fname);
    
    fname = fullfile(set.raw_subexp, [ folderContent.fname_list{nsubExp}(1:end-4) '.png']);
    imwrite(subexp, fname);
    
end
