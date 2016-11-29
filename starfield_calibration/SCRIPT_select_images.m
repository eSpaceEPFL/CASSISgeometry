% Scripts selects images that will be used in farther processing
% Output:
% * Table with acquisition time, exposure time for selected images

function SCRIPT_select_images()

% ------------------------------------------------------------------------

dataset_path = '/HDD1/Data/CASSIS/2015_06_23_CASSIS_STARFIELD';
dataset_name = 'pointing_cassis';
exposure_min = 0.1 % sec

% ------------------------------------------------------------------------ 

fprintf('Selecting CaSSIS images for farther processing from %s set\n', dataset_name);

set = cassis_starfield_dataset(dataset_path, dataset_name);
imglist = readtable(set.imglist);
imglist = table2struct(imglist)
nb_images = length(imglist);

fprintf('%i images were found\n', nb_images);
fprintf('Selecting images:\n');
accepted_idx = [];
for nimage = 1:nb_images

    fprintf('%s done..', imglist(nimage).time);
    
    % check ignorelist
    if( cassis_check_ignorelist(set.ignorelist, imglist(nimage).time) )
        fprintf('ignored, as from ignorelist\n');
    else
        % check exposure time
        if( imglist(nimage).exposure < exposure_min )
            fprintf('ignored, as short exposure image\n');
        else
            fprintf('accepted\n');
            accepted_idx = [accepted_idx; nimage];
        end
    end
        
end

fprintf('Totally %i images were selected\n', length(accepted_idx));

activelist = imglist(accepted_idx);
activelist = struct2table(activelist)
writetable(activelist, set.activelist);
    
end