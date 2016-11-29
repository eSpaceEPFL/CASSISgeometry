% Given table of detected star SCRIPT divides it into training set and test
% set. Note that the SCRIPT does not check that there is enought points in
% training set for rotation estimation!

function SCRIPT_divide_set()

%% Input 
prm.prc_test = 0.03;
all_data_fname = 'DATA_inlier_data_ra_dec_x_y_time.csv';
test_set_fname = 'DATA_test_set_ra_dec_x_y_time.csv';
train_set_fname = 'DATA_train_set_ra_dec_x_y_time.csv';

%% Read input
ra_dec_x_y_time = dlmread(all_data_fname,',',1,0);
nb_points = size(ra_dec_x_y_time, 1);

%% Make test and training set
fprintf('Preparing training and test set:\n');
randseed(1); % for repetability
times = unique(ra_dec_x_y_time(:,end));
test_ra_dec_x_y_time = [];
train_ra_dec_x_y_time = [];

for ntime = 1:length(times)
    ra_dec_x_y_time_subset = ra_dec_x_y_time(ra_dec_x_y_time(:,5)==times(ntime),:);
    nb_subset_points = size(ra_dec_x_y_time_subset, 1);
    randvec = randperm(nb_subset_points);
    nb_test_points = round(nb_subset_points*prm.prc_test);
    test_ra_dec_x_y_time =[test_ra_dec_x_y_time; ra_dec_x_y_time_subset(randvec(1:nb_test_points),:)];
    train_ra_dec_x_y_time =[train_ra_dec_x_y_time; ra_dec_x_y_time_subset(randvec(nb_test_points + 1:end),:)];
end

fprintf('Test set contains %i points\n', size(test_ra_dec_x_y_time,1));
fprintf('Training set contains %i points\n', size(train_ra_dec_x_y_time,1));

% save training set
fid = fopen(train_set_fname, 'w');
fprintf(fid, '%% ra [deg], dec [deg], x [px], y[px], time [days from 0 year]\n');
fclose(fid);
dlmwrite(train_set_fname, train_ra_dec_x_y_time, '-append', 'delimiter', ',', 'precision', 20);

% save test set 
fid = fopen(test_set_fname, 'w');
fprintf(fid, '%% ra [deg], dec [deg], x [px], y[px], time [days from 0 year]\n');
fclose(fid);
dlmwrite(test_set_fname, test_ra_dec_x_y_time, '-append', 'delimiter', ',', 'precision', 20);

end