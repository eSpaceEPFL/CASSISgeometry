% Script divides all point in test and training set
clear all; clc;

prc_test = 0.2;
match_table_fname = 'collect_ra_dec_x_y_time.csv';

ra_dec_x_y_time = csvread(match_table_fname);
nb_points = size(ra_dec_x_y_time, 1);

%% Make test and training set
% Here we have to make sure that for every image there are at least 
% several point in training set, since we need to estimate angles for
% every image
fprintf('Preparing training and test set:\n');
randseed(1); % for repetability
times = unique(ra_dec_x_y_time(:,end));
test_ra_dec_x_y_time = [];
train_ra_dec_x_y_time = [];

for ntime = 1:length(times)
    ra_dec_x_y_time_subset = ra_dec_x_y_time(ra_dec_x_y_time(:,5)==times(ntime),:);
    nb_subset_points = size(ra_dec_x_y_time_subset, 1);
    randvec = randperm(nb_subset_points);
    nb_test_points = round(nb_subset_points*prc_test);
    test_ra_dec_x_y_time =[test_ra_dec_x_y_time; ra_dec_x_y_time_subset(randvec(1:nb_test_points),:)];
    train_ra_dec_x_y_time =[train_ra_dec_x_y_time; ra_dec_x_y_time_subset(randvec(nb_test_points + 1:end),:)];
end

fprintf('Test set contains %i points\n', size(test_ra_dec_x_y_time,1));
fprintf('Training set contains %i points\n', size(train_ra_dec_x_y_time,1));
dlmwrite('test_ra_dec_x_y_time.csv', test_ra_dec_x_y_time, 'delimiter', ',', 'precision', 20);
dlmwrite('train_ra_dec_x_y_time.csv', train_ra_dec_x_y_time, 'delimiter', ',', 'precision', 20);
