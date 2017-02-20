function SCRIPT_collect_star(dataset_name)

 %%

dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));

%%
clc
fprintf('Initializing rotation from SPICE kernel\n');

% read folders structure
set = DATASET_starfields(dataset_path, dataset_name);

% read exposures summary
expSummary = readtable(set.exposuresSummary);
nb_exp = height(expSummary);

for nexp = 1:nb_exp
    
    % read exposure
    fname = [set.recognize '/'  expSummary.fname_exp{nexp} '.csv'];
    starSummary = readtable(fname);
    nb_stars = height(starSummary);
    fprintf('%s: %i stars...\n', expSummary.fname_exp{nexp}, nb_stars);
    
    if nb_stars > 0 
        
        time = cell(nb_stars,1);
        time(:) = expSummary.t_list_(nexp);
        starSummary.time = time;
    
        if exist('allStarSummary','var') 
            allStarSummary = [allStarSummary; starSummary];
        else
            allStarSummary = starSummary;
        end
    end
    
end 

fprintf('Totally %i stars...\n', height(allStarSummary));
figure;
scatter(allStarSummary.x, allStarSummary.y, [], cassis_time2num(allStarSummary.time));
writetable(allStarSummary, set.allStarSummary); 
        