% Scripts extracts raw CaSSIS images from datastripes
% Output:
% * Table with acquisition time, exposure time
% * Raw images in tif format
% * Masks with exposed regions

function SCRIPT_cassis2raw()

% ------------------------------------------------------------------------

dataset_path = '/HDD1/Data/CASSIS/2016_09_20_CASSIS_STARFIELD';
dataset_name = 'mcc_motor';

% ------------------------------------------------------------------------ 

addpath('xml2struct');   % to read xml information of CaSSIS 

fprintf('Extracting raw CaSSIS images from %s set\n', dataset_name);

set = cassis_starfield_dataset(dataset_path, dataset_name);
time = cassis_find_images(set.level0);

nb_images = length(time);
mult = (2^16-1)/(2^14-1); % 14bit images in 16bit

fprintf('%i images were found\n', nb_images);
fprintf('decoding images:\n');
f = figure;

for nimage = 1:nb_images

    fprintf('%s done..\n', time{nimage});
    
    % save raw images
    [I, mask, exposure(nimage)] = cassis_read_image(set.level0, time{nimage});
    image_tif_fname = [set.raw '/' time{nimage} '_raw.tif'];
    mask_tif_fname = [set.raw '/' time{nimage} '_mask.tif'];
    imwrite(uint16(double(I)*mult), image_tif_fname);
    imwrite(mask, mask_tif_fname);
    
    % save visualization
    image_tif_fname = [set.raw '/' time{nimage} '_vis.tif'];
    I = imadjust(im2double(I), stretchlim(im2double(I(mask))));
    imwrite(I, image_tif_fname);
    figure(f); imshow(I);
    
    pause(0.1);
end

exposure = exposure';
time = time';
imglist = table(time, exposure);
writetable(imglist, set.imglist);
    
end