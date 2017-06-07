% Given table of detected stars, SCRIPT filters-out potential outliers.
% Filtering process basically eliminates star that do not reappear in
% several consequtive frames. SCRIPT also eliminates frames that do not have 
% enougth stars.

function SCRIPT_filter_outliers(set)


 %%

%dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));

time_th = 30e-4; % 30 sec 
ispace_th = 0.5;
if( strcmp(set.name, 'commissioning_2' ) || strcmp(set.name, 'pointing_cassis' ))
    neigh = 1;
else
    neigh = 2;
end
min_points_per_image = 10;
flux_th = 3000;

%%
clc
fprintf('Starting outliers detection procedure: \n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

% read stars summary
allStarSummary = readtable(set.allStarSummary);
nb_stars = height( allStarSummary );
fprintf('Starting with %i stars\n', nb_stars);

% Remove faint
mask = allStarSummary.flux > flux_th;
allStarSummary = allStarSummary(mask,:);

% Remove points that are not reconfirmed in several frames
% make unweighted image space adjacency matrix
A_ispace = pdist2([allStarSummary.x allStarSummary.y], [allStarSummary.x allStarSummary.y]);
A_ispace = A_ispace <= ispace_th;

% make unweighted time adjacency matrix
A_time = pdist2(cassis_time2num(allStarSummary.time),cassis_time2num(allStarSummary.time));
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
        allStarSummary = allStarSummary(~mask,:);
        bins = bins(~mask);
    end
end

nb_stars = height( allStarSummary );
fprintf('%i stars passed multiframe confirmation procedure\n',nb_stars)


% Remove frames that do not contain enougth stars
unique_time = unique(cassis_time2num(allStarSummary.time)) ;
nb_time = length(unique_time);
for ntime = 1:nb_time
    mask = unique_time(ntime) == cassis_time2num(allStarSummary.time);
    if( nnz(mask) < min_points_per_image )
        allStarSummary = allStarSummary(~mask,:);
    end
end

nb_stars = height( allStarSummary );
fprintf('%i stars passed minimum stars in frame requirement\n', nb_stars)

% Reporting and saving results
% show density stars in frame
unique_time = unique( cassis_time2num(allStarSummary.time) ) ;
nb_time = length(unique_time);
text = {};
f = figure('units','normalized','outerposition',[0 0 1 1]);
for ntime = 1:nb_time
    index = unique_time(ntime) == cassis_time2num(allStarSummary.time);
    plot(allStarSummary.x(index), allStarSummary.y(index), 'o'); hold on;
    text{ntime} = [cassis_num2time(unique_time(ntime)) ' : ' num2str(nnz(index)) ' stars']; 
end
ax = gca;
ax.YDir = 'reverse';
ax.XAxisLocation = 'top'
axis([0 2048 0 2048]);
legend(text,'Location', 'bestoutside');
grid on;
hgexport(f, set.inlierStarSummary_IMG,  ...
     hgexport('factorystyle'), 'Format', 'png'); 

writetable(allStarSummary, set.inlierStarSummary);

end
