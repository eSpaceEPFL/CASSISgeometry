% Script recogizes stars stars

function SCRIPT_recognize()

% ------------------------------------------------------------------------

%dataset_path = '/HDD1/Data/CASSIS/2015_06_23_CASSIS_STARFIELD';
%dataset_name = 'commissioning_2';

dataset_path = '/HDD1/Data/CASSIS/2016_09_20_CASSIS_STARFIELD';
dataset_name = 'mcc_abs_cal';

%dataset_path = '/HDD1/Data/CASSIS/2016_09_20_CASSIS_STARFIELD';
%dataset_name = 'mcc_motor';

% ------------------------------------------------------------------------     

set = cassis_starfield_dataset(dataset_path, dataset_name);
activelist = readtable(set.imglist);
activelist = table2struct(activelist);
nb_images = length(activelist);

fprintf('Detecting stars:\n');
f = figure;
for nimage = 1:nb_images
    fprintf('%s...', activelist(nimage).time);
    
    % copy image to temp folder
    delete('work/1st/*'); 
    delete('work/2nd/*'); 
    fname = [set.denoise '/' activelist(nimage).time '_denoise.tif'];
    copyfile(fname, 'work/1st/tmp.tif');
    copyfile(fname, 'work/2nd/tmp.tif');
    I = imread(fname);

    % detect stars
    sys_command = ['solve-field --parity pos --no-plots --downsample 2  work/1st/tmp.tif'];
    system(sys_command);
    
    % rerun to find more matches
    if exist('work/1st/tmp.wcs','file' )== 2
        copyfile('work/1st/tmp.wcs', 'work/2nd/1st_attemt.wcs');
        sys_command = ['solve-field --no-plots --parity pos --verify work/2nd/1st_attemt.wcs work/2nd/tmp.tif'];
        system(sys_command);
    end
       
    % parse output
    match_list = [];
    figure(f);
    
    if exist('work/2nd/tmp.corr', 'file') == 2
    
        info = fitsinfo('work/2nd/tmp.corr');
        tableData = fitsread('work/2nd/tmp.corr','binarytable');
        x = tableData{1};
        y = tableData{2}; 
        ra = tableData{7};
        dec = tableData{8};
        match_list = [ra dec x y];
        shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor', 'white')
        I = step(shapeInserter, cat(3,I,I,I), int32([x(:) y(:) 5*ones(numel(x),1)])); 
        imshow(I); hold on;
    end
       
    imwrite(im2double(I),[set.recognize '/' activelist(nimage).time '.tif'])
    fprintf(' %i stars matched \n', size(match_list,1));
    pause(0.1)
    
    % save stars
    fname = [set.recognize '/' activelist(nimage).time '_matchlist.txt'];
    dlmwrite(fname, match_list, ' ');
end
end



