% Given setnames Script collects all matched stars in one file.
 
% * It eliminates data points that have neighbourhood in time but dont have 
%   neighbourhood in sapce
% * It removes image if there is not enought data point in the image


% input parameters
subsetnames = {'commissioning_2'};
dataset_path = '/HDD1/Data/CASSIS/2015_06_23_CASSIS_STARFIELD';

% output 
all_data_fname = 'work/DATA_all_data_ra_dec_x_y_time.csv'

collect_ra_dec_x_y_time = [];
for nsubset = 1:length(subsetnames)

    
    set = cassis_starfield_dataset(dataset_path, subsetnames{nsubset});
    activelist = readtable(set.activelist);
    activelist = table2struct(activelist);
    nb_images = length(activelist);

    for nimage = 1:nb_images
        
        fprintf('%s: %s...', subsetnames{nsubset}, activelist(nimage).time);
        
        fname = [set.recognize '/' activelist(nimage).time '_matchlist.txt'];
        
        try
            ra_dec_x_y = dlmread(fname, ' ');
        catch
            continue;
        end
        
        fprintf(' %i stars found, ', length(ra_dec_x_y));

        if( ~isempty(ra_dec_x_y) )
            
            time_num = cassis_time2num(activelist(nimage).time);
            ra_dec_x_y_time = [ra_dec_x_y repmat(time_num, size(ra_dec_x_y, 1), 1)];
            collect_ra_dec_x_y_time = [collect_ra_dec_x_y_time; ra_dec_x_y_time];
            fprintf(' %i stars added', length(ra_dec_x_y));

        end
        fprintf('\n');
    end
end

% % check that every time neighbourhood points are also space neighbourhood
% [~, space_dist] = knnsearch(collect_ra_dec_x_y_time(:,3:4), collect_ra_dec_x_y_time(:,3:4), 'k', 2);
% not_valid = space_dist(:,2) > space_neigh_th;
% collect_ra_dec_x_y_time = collect_ra_dec_x_y_time(~not_valid,:);
% 
% % check   
% unique_time = unique(collect_ra_dec_x_y_time(:,5)); 
% nb_unique_time = length(unique_time);
% for ntime = 1:nb_unique_time
%     mask = collect_ra_dec_x_y_time(:,5) == unique_time(ntime);
%     if( nnz(mask) < min_points_per_image )
%         collect_ra_dec_x_y_time = collect_ra_dec_x_y_time(~mask,:);
%     end
% end


%[~, dist] = knnsearch(collect_ra_dec_x_y_time(:,3:4), ra_dec_x_y(:,3:4));
%ra_dec_x_y_time(ind_2,:)
% add only point that are far from existing points
%             if( ~isempty(collect_ra_dec_x_y_time) )
%                 valid = (dist >= min_dist_btw_points);
%                 ra_dec_x_y = ra_dec_x_y(valid,:); 
%             end
%                     
%             % if there are enought points add 
%             nb_points = size(ra_dec_x_y,1);
%             if( nb_points >= min_points_per_image )
%                 
%                 % add time
%                 time_num = cassis_time2num(activelist(nimage).time);
%                 ra_dec_x_y_time = [ra_dec_x_y repmat(time_num, size(ra_dec_x_y, 1), 1)];
%                 
%                 collect_ra_dec_x_y_time = [collect_ra_dec_x_y_time; ra_dec_x_y_time];
%                 fprintf(' %i stars added', length(ra_dec_x_y));
%             end
%         end
%         fprintf('\n');
        
figure;
scatter(collect_ra_dec_x_y_time(:,3), collect_ra_dec_x_y_time(:,4), [],collect_ra_dec_x_y_time(:,5));

fid = fopen(all_data_fname, 'w');
fprintf(fid, '%% ra [deg], dec [deg], x [px], y[px], time [days from 0 year]\n');
fclose(fid);
dlmwrite(all_data_fname, collect_ra_dec_x_y_time, '-append', 'delimiter', ',', 'precision', 20);
fprintf('In total: %i stars\n', length(collect_ra_dec_x_y_time));



