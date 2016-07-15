% Script detects stars
clear all; clc;

dataset_path = '/HDD1/Data/CASSIS/2015_06_23_CASSIS_STARFIELD';
set = cassis_starfield_dataset(dataset_path, 'commissioning_2');
frames = cassis_find_images(set.level0);
nb_images = length(frames.time);

fprintf('Detecting stars:\n');
f = figure;
for nimage = 1:nb_images
    fprintf('%s...', frames.time{nimage});
    
    % copy image to temp folder
    delete('tmp/1st/*'); 
    delete('tmp/2nd/*'); 
    fname = [set.denoise '/' frames.time{nimage} '_denoise.tif'];
    copyfile(fname, 'tmp/1st/tmp.tif');
    copyfile(fname, 'tmp/2nd/tmp.tif');
    % detect stars
    sys_command = ['solve-field  --downsample 2  tmp/1st/tmp.tif'];
    system(sys_command);
    % rerun to find more matches
    copyfile('tmp/1st/tmp.wcs', 'tmp/2nd/1st_attemt.wcs');
    sys_command = ['solve-field --verify tmp/2nd/1st_attemt.wcs tmp/2nd/tmp.tif'];
    system(sys_command);
       
    % parse output
    match_list = [];
    figure(f);
    imshow(imread(fname)); hold on;

    if exist('tmp/2nd/tmp.corr', 'file') == 2
        info = fitsinfo('tmp/2nd/tmp.corr');
        tableData = fitsread('tmp/2nd/tmp.corr','binarytable');
        x = tableData{1};
        y = tableData{2};
        ra = tableData{7};
        dec = tableData{8};
        match_list = [ra dec x y];
        plot(x,y,'o');
    end
    
    fprintf(' %i stars matched \n', size(match_list,1));
    pause(0.1)
    
    % save stars
    fname = [set.recognize '/' frames.time{nimage} '_matchlist.txt'];
    dlmwrite(fname, match_list, ' ');
end




