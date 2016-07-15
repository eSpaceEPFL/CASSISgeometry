% Script flattens images, substracts dark field, mask out problems
clear all; clc;

dataset_path = '/HDD1/Data/CASSIS/2015_06_23_CASSIS_STARFIELD';
set = cassis_starfield_dataset(dataset_path, 'pointing_spacecraft');
frames = cassis_find_images(set.level0);
nb_images = length(frames.time);

fprintf('Flatten images and compute dark frame\n');
parfor nimage = 1:nb_images
    image_tif_fname = [set.raw '/' frames.time{nimage} '_raw.tif'];
    mask_tif_fname = [set.raw '/' frames.time{nimage} '_mask.tif'];
   
    % flatten
    I = im2double(imread(image_tif_fname));
    I_median = (medfilt2((I), [7 7]));   
    I = I - I_median;
    
    % normalize contrast
    mask = imread(mask_tif_fname);
    I = imadjust(I, stretchlim(I(mask)));
    Istack(:,:,nimage) = I;
        
end

% find darkframe
Idark = median(Istack,3);

fprintf('Substracting dark frame:\n');
f = figure;
for nimage = 1:nb_images
    fprintf('%s...\n', frames.time{nimage});
    
    % substract dark frame
    I = max(Istack(:,:,nimage) - Idark,0);
    I = uint16(I*(2^16-1));
    
    % mask out problems
    problem_mask = imread('mask.png') == 255;
    I(problem_mask) = 0;
    fname = [set.denoise '/' frames.time{nimage} '_denoise.tif'];
    imwrite(I,fname); 
    
    % save visualization
    image_tif_fname = [set.denoise '/' frames.time{nimage} '_vis.tif'];
    mask_tif_fname = [set.raw '/' frames.time{nimage} '_mask.tif'];
    mask = imread(mask_tif_fname);
    I = imadjust(I, stretchlim(I(mask)));
    imwrite(I, image_tif_fname);
    figure(f); imshow(I);    
    pause(0.1);
end




