% Given setnames script collects all matched stars in one large file.
% It eliminates data points that are two close in image space.
% It also eliminates images that does not contain sufficient datapoins

clear all; clc;

% Parameters
subsetnames = {'commissioning_2'};
dataset_path = '/HDD1/Data/CASSIS/2015_06_23_CASSIS_STARFIELD';
min_points_per_image = 5;
min_dist_btw_points = 5;

collect_ra_dec_x_y_time = [];

for nsubset = 1:length(subsetnames)

    set = cassis_starfield_dataset(dataset_path, subsetnames{nsubset});
    frames = cassis_find_images(set.level0);
    nb_images = length(frames.time);

    for nimage = 1:nb_images
        
        fprintf('%s: %s...', subsetnames{nsubset}, frames.time{nimage});
        
        fname = [set.recognize '/' frames.time{nimage} '_matchlist.txt'];
        ra_dec_x_y = dlmread(fname, ' ');
        
        fprintf(' %i stars found, ', length(ra_dec_x_y));

        if( ~isempty(ra_dec_x_y) )
       
            % add only point that are far from existing points
            if( ~isempty(collect_ra_dec_x_y_time) )
                [~, dist] = knnsearch(collect_ra_dec_x_y_time(:,3:4), ra_dec_x_y(:,3:4));
                valid = (dist >= min_dist_btw_points);
                ra_dec_x_y = ra_dec_x_y(valid,:); 
            end
                    
            % if there are enought points add 
            if( length(ra_dec_x_y) >= min_points_per_image )
                
                % add time
                time_num = cassis_time2num(frames.time{nimage});
                collect_ra_dec_x_y_time = [collect_ra_dec_x_y_time; [ra_dec_x_y repmat(time_num, size(ra_dec_x_y, 1), 1)]];
                fprintf(' %i stars added', length(ra_dec_x_y));
            end
        end
        fprintf('\n');
    end
end

figure;
scatter(collect_ra_dec_x_y_time(:,3), collect_ra_dec_x_y_time(:,4), [],collect_ra_dec_x_y_time(:,5));

% save
csvwrite('collect_ra_dec_x_y_time.csv', collect_ra_dec_x_y_time);
fprintf('In total: %i stars\n', length(collect_ra_dec_x_y_time));



