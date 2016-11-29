% Given table of detected stars, SCRIPT filters-out potential outliers.
% Filtering process basically eliminates star that do not reappear in
% several consequtive frames. SCRIPT also eliminates frames that do not have 
% enougth stars.

function SCRIPT_filter_outliers()

clc;
fprintf('Starting outliers detection procedure: \n');

%% Input

all_data_fname = 'work/DATA_all_data_ra_dec_x_y_time.csv';
inlier_data_fname = 'work/DATA_inlier_data_ra_dec_x_y_time.csv';
time_th = 5e-4;
ispace_th = 3;
neigh = 3; 
min_points_per_image = 30; 

%% Reading input
ra_dec_x_y_time = dlmread(all_data_fname,',',1,0);
nb_points = size(ra_dec_x_y_time, 1);

fprintf(['Starting with ' num2str( size(ra_dec_x_y_time, 1) ) ' stars\n']);

%% Remove points that are not reconfirmed in several frames
% make unweighted image space adjacency matrix
A_ispace = pdist2(ra_dec_x_y_time(:,3:4),ra_dec_x_y_time(:,3:4));
A_ispace = A_ispace <= ispace_th;

% make unweighted time adjacency matrix
A_time = pdist2(ra_dec_x_y_time(:,5),ra_dec_x_y_time(:,5));
A_time = A_time <= time_th;

A = A_time.*A_ispace;

% make graph
G = graph(A, 'OmitSelfLoops'); 

% compute degree of vertices
bins = conncomp(G);

% collect poins 
unique_bins = unique(bins);
nb_bins = length(unique_bins);
for nbin = 1:nb_bins
    mask = unique_bins(nbin) == bins;
    if nnz(mask) < neigh
        ra_dec_x_y_time = ra_dec_x_y_time(~mask,:);
        bins = bins(~mask);
    end
end

fprintf([num2str(size(ra_dec_x_y_time,1)) ' stars passed multiframe confirmation procedure\n'])

%% Remove frames that do not contain enougth stars
unique_time = unique(ra_dec_x_y_time(:,5)) ;
nb_time = length(unique_time);
for ntime = 1:nb_time
    mask = unique_time(ntime) == ra_dec_x_y_time(:,5);
    if( nnz(mask) < min_points_per_image )
        ra_dec_x_y_time = ra_dec_x_y_time(~mask,:);
    end
end

fprintf([num2str(size(ra_dec_x_y_time,1)) ' stars passed minimum stars in frame requirement\n'])

%% Reporting and saving results
% show density stars in frame
unique_time = unique(ra_dec_x_y_time(:,5)) ;
nb_time = length(unique_time);
text = {};
figure;
for ntime = 1:nb_time
    index = unique_time(ntime) == ra_dec_x_y_time(:,5) ;
    plot(ra_dec_x_y_time(index,3), ra_dec_x_y_time(index,4), 'o');
    text{ntime} = [cassis_num2time(unique_time(ntime)) ' : ' num2str(nnz(index)) ' stars']; 
    hold on;
end
legend(text,'Location', 'bestoutside');
axis([0 2048 0 2048]);
set(gca, 'ydir', 'reverse');
set(gca,'xaxislocation','top');
grid on;
hold off;


fid = fopen(inlier_data_fname, 'w');
fprintf(fid, '%% ra [deg], dec [deg], x [px], y[px], time [days from 0 year]\n');
fclose(fid);
dlmwrite(inlier_data_fname, ra_dec_x_y_time, '-append', 'delimiter', ',', 'precision', 20);

end
