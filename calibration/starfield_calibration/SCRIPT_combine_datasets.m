function SCRIPT_combine_datasets(combined_set_name, sets_names)

%%

%combined_set_name = 'commissioning2_mcc_motor';
%sets_names = {'mcc_motor', 'commissioning_2'};

dataset_path = '/home/tulyakov/Desktop/espace-server';
addpath(genpath('../libraries'));

%%

nb_sets = length(sets_names);
fprintf('Combining datasets\n');

% read folders structure
comb_set = DATASET_starfields(dataset_path, combined_set_name);

for nset = 1:nb_sets 
        
    fprintf('Dataset %s\n', sets_names{nset});
    
    % combine exposures summary
    cur_set = DATASET_starfields(dataset_path, sets_names{nset});
    
    if nset == 1
        inlierStarSummary = readtable(cur_set.inlierStarSummary);
        expSummary = readtable(cur_set.exposuresSummary);
    else
        inlierStarSummary = [inlierStarSummary; readtable(cur_set.inlierStarSummary)];
        expSummary = [expSummary; readtable(cur_set.exposuresSummary)];
    end
    
end


% Reporting and saving results show density stars in frame
unique_time = unique( cassis_time2num(inlierStarSummary.time) ) ;
nb_time = length(unique_time);
text = {};
f = figure('units','normalized','outerposition',[0 0 1 1]);
for ntime = 1:nb_time
    index = unique_time(ntime) == cassis_time2num(inlierStarSummary.time);
    plot(inlierStarSummary.x(index), inlierStarSummary.y(index), 'o'); hold on;
    text{ntime} = [cassis_num2time(unique_time(ntime)) ' : ' num2str(nnz(index)) ' stars']; 
end
ax = gca;
ax.YDir = 'reverse';
ax.XAxisLocation = 'top'
axis([0 2048 0 2048]);
legend(text,'Location', 'bestoutside');
grid on;
hgexport(f, comb_set.inlierStarSummary,  ...
     hgexport('factorystyle'), 'Format', 'png'); 


writetable(expSummary, comb_set.exposuresSummary); 
writetable(inlierStarSummary, comb_set.inlierStarSummary); 


end
