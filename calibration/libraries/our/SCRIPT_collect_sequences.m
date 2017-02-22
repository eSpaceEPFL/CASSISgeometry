% Scripts extracts raw CaSSIS images from datastripes
% Output:
% * Table with acquisition time, exposure time
% * Raw images in tif format
% * Masks with exposed regions

function SCRIPT_collect_sequences(set)

%% params and dependencies

%dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));
%islevel0 = true;

%%
clc
fprintf('Extracting raw CaSSIS images from %s set\n', set.name);

% read folder structure
%set = DATASET_starfields(dataset_path, dataset_name);

% load folder content summary
folderContent = readtable(set.folderContent);
seq_ids = unique(folderContent.seq_list)';
nb_seq = length(seq_ids);

%%%
%seq_ids = setdiff(seq_ids,0)


fprintf('%i sequences were found\n', nb_seq);
fprintf('Decoding sequences:\n');

i = 1;
for id = seq_ids
    
    fprintf('Sequence # %i started..\n', id);
    
    % get sequence content
    seqIndices = find(folderContent.seq_list == id);
    indices = seqIndices;
    seqContent = folderContent(indices,:);
    
    % make and save sequence object
    if isfield(set, 'level1')
        seq = exposureSequence(set.level1, seqContent.fname_list, false);
    else
        seq = exposureSequence(set.level0, seqContent.fname_list, true);
    end
    
    exp_time(i) = seq.exposure_time; 
    nb_exp(i) = length(unique(seqContent.exp_list));
    start_time{i} = seqContent.t_list_{1};
    finish_time{i} = seqContent.t_list_{end};
    
    save([set.sequences '/' start_time{i} '~' finish_time{i} '.mat'], 'seq');
    i = i + 1;    
       
    pause(0.1);
    
end

% save sequecence summary
seq_list = seq_ids';
start_time = start_time';
finish_time = finish_time';
nb_exp = nb_exp';
exp_time = exp_time';

seqSummary = table(seq_list, start_time, finish_time, exp_time, nb_exp);
writetable(seqSummary, set.sequencesSummary); 
    
end