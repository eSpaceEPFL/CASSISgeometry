% Script recogizes stars stars

function SCRIPT_recognize(dataset_name)

%%

dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));
flux_th = 1800;

%%
clc
fprintf('Detecting and recognising stars\n');

% read folders structure
set = DATASET_starfields(dataset_path, dataset_name);

% read exposures summary
expSummary = readtable(set.exposuresSummary);
nb_exp = height(expSummary);

%-------------------------------------------------------------------------

f = figure;
for nexp = 1:nb_exp
    
    fprintf('%s...\n', expSummary.fname_exp{nexp});
        
    % copy image to temp folder
    delete('work/1st/*'); 
    delete('work/2nd/*'); 
    fname = [set.denoise_exposure '/' expSummary.fname_exp{nexp}];
    copyfile(fname, 'work/1st/tmp.tif');
    copyfile(fname, 'work/2nd/tmp.tif');
    I = imread(fname);

    % detect stars
    sys_command = ['solve-field --parity pos  --no-plots --cpulimit 5 --downsample 2 --pixel-error 15   work/1st/tmp.tif'];
    system(sys_command);
    
    % rerun to find more matches
    if exist('work/1st/tmp.wcs','file' )== 2
        copyfile('work/1st/tmp.wcs', 'work/2nd/1st_attemt.wcs');
        sys_command = ['solve-field --parity pos  --no-plots --pixel-error 15 --verify work/2nd/1st_attemt.wcs work/2nd/tmp.tif'];
        system(sys_command);
    end
       
    % parse output
    match_list = [];
    figure(f);
    
    if exist('work/2nd/tmp.corr', 'file') == 2
    
        info = fitsinfo('work/2nd/tmp.corr');
        tableData = fitsread('work/2nd/tmp.corr','binarytable');
        flux = tableData{12};
        x = tableData{1};
        y = tableData{2}; 
        ra = tableData{7};
        dec = tableData{8};
        if length(flux) > 0 
            shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor', 'white')
            I = step(shapeInserter, cat(3,I,I,I), int32([x(:) y(:) 5*ones(numel(x),1)])); 
           % imshow(I); hold on;
        end
        
    end
       
    imwrite(I,[set.recognize '/' expSummary.fname_exp{nexp}])
    fprintf(' %i stars matched \n', size(match_list,1));
    pause(0.1)
    
    % save stars
    fname = [set.recognize '/'  expSummary.fname_exp{nexp} '.csv'];
    starSummary = table(x, y, ra, dec, flux);
    writetable(starSummary, fname); 
end



