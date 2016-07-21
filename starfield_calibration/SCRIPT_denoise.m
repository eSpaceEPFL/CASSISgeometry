% Script flattens images, substracts dark field, mask out problems
clear all; clc;

dataset_path = '/HDD1/Data/CASSIS/2015_06_23_CASSIS_STARFIELD';
set = cassis_starfield_dataset(dataset_path, 'commissioning_2');
frames = cassis_find_images(set.level0);
nb_images = length(frames.time);
problem_mask = imread('mask.png') == 255;

fprintf('Flatten images and compute dark frame\n');
for nimage = 1:nb_images
    image_tif_fname = [set.raw '/' frames.time{nimage} '_raw.tif'];
    mask_tif_fname = [set.raw '/' frames.time{nimage} '_mask.tif'];
    I = im2double(imread(image_tif_fname));
    empty_mask = imread(mask_tif_fname);
    mask = ~empty_mask | problem_mask; 
    maskStack(:,:,nimage) = mask;
    
    % flatten
    I_median = (medfilt2((I), [9 9]));   
    I = max(I - I_median,0);
    
    % normalize contrast
    I = imadjust(I, stretchlim(I(~mask)));
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
    
    % mask artifacts and empty
    mask = maskStack(:,:,nimage);
    I(mask) = 0;

    % save
    fname = [set.denoise '/' frames.time{nimage} '_denoise.tif'];
    imwrite(I,fname); 
   
    
    % save visualization
    image_tif_fname = [set.denoise '/' frames.time{nimage} '_vis.tif'];
    mask_tif_fname = [set.raw '/' frames.time{nimage} '_mask.tif'];
    I = imadjust(I, stretchlim(I(~mask)));
    imwrite(I, image_tif_fname);
    figure(f); imshow(I);    
    pause(0.1);
end




