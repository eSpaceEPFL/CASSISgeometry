% Scripts produces raw image, given level0

clc; clear all;

% Set path to dataset provided by UniBern and name of subset
dataset_path = '/HDD1/Data/CASSIS/2015_06_23_CASSIS_STARFIELD';
set = cassis_starfield_dataset(dataset_path, 'pointing_cassis');
frames = cassis_find_images(set.level0);
nb_images = length(frames.time);
mult = (2^16-1)/(2^14-1); % 14bit images in 16bit

fprintf('%i images were found\n', nb_images);
fprintf('decoding images:\n');
f = figure;

parfor nimage = 1:nb_images
    fprintf('%s done..\n', frames.time{nimage});
    
    % save raw images
    [I, mask] = cassis_read_image(set.level0, frames.time{nimage});
    image_tif_fname = [set.raw '/' frames.time{nimage} '_raw.tif'];
    mask_tif_fname = [set.raw '/' frames.time{nimage} '_mask.tif'];
    imwrite(uint16(double(I)*mult), image_tif_fname);
    imwrite(mask, mask_tif_fname);
    
    % save visualization
    image_tif_fname = [set.raw '/' frames.time{nimage} '_vis.tif'];
    I = imadjust(im2double(I), stretchlim(im2double(I(mask))));
    imwrite(I, image_tif_fname);
    figure(f); imshow(I);    
    pause(0.1);
end