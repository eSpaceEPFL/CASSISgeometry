% Script flattens images, substracts dark field, masks out problems

function SCRIPT_denoise()

% ------------------------------------------------------------------------

defects_mask_fname = 'sensor_defects_mask.png';
dataset_path = '/HDD1/Data/CASSIS/2015_06_23_CASSIS_STARFIELD';
dataset_name = 'pointing_cassis';

%-------------------------------------------------------------------------

set = cassis_starfield_dataset(dataset_path, dataset_name);
activelist = readtable(set.activelist);
activelist = table2struct(activelist);
nb_images = length(activelist);

%problem_mask = imread(defects_mask_fname) == 255;
%problem_mask = zeros(size(problem_mask));

fprintf('Flatten images and compute dark frame\n');

for nimage = 1:nb_images
    
    image_tif_fname = [set.raw '/' activelist(nimage).time '_raw.tif'];
    mask_tif_fname = [set.raw '/' activelist(nimage).time '_mask.tif'];
    
    
    I = im2double(imread(image_tif_fname));
    empty_mask = imread(mask_tif_fname);
    mask = ~empty_mask ;
    maskStack(:,:,nimage) = mask;
    
    % flatten
    I_median = (medfilt2((I), [9 9]));
    I = max(I - I_median,0);
    
    % normalize contrast

    Istack(:,:,nimage) = I;
    
end

% find darkframe
Idark = median(Istack, 3);

fprintf('Substracting dark frame:\n');
f = figure;
for nimage = 1:nb_images
    fprintf('%s...\n', activelist(nimage).time);
    
    mask = maskStack(:,:,nimage);
    
    % substract dark frame
    I = max(Istack(:,:,nimage) - Idark,0);
    I = (I - min(I(~mask)))./range(I(~mask)) ;
    I = uint16(I*(2^16-1));
    
    % mask artifacts and empty
    I(mask) = 0;

    % save
    fname = [set.denoise '/' activelist(nimage).time '_denoise.tif'];
    imwrite(I,fname); 
   
    % save visualization
%    image_tif_fname = [set.denoise '/' activelist(nimage).time '_vis.tif'];
%    mask_tif_fname = [set.raw '/' activelist(nimage).time '_mask.tif'];
%    imwrite(I, image_tif_fname);
    figure(f); imshow(I);    
    pause(0.1);
end

end


