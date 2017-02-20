% Script flattens images, substracts dark field, masks out problems

function SCRIPT_save_rawExp(set)

%% params and dependencies

%dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));
mult = 1/(2^16-1); % 14bit images in 16bit
%islevel0 = true;
skipFirst = 1;

%%

fprintf('Saving individual exposures for every sequence of %s dataset \n', dataset_name);
%if( islevel0 )
%    fprintf('(assuming level 0)\n');
%else
%    fprintf('(assuming level 1)\n');
%end

% read folder structure
%set = DATASET_starfields(dataset_path, dataset_name);

% load sequences summary
seqSummary = readtable(set.sequencesSummary);
nb_seq = height(seqSummary);
f = figure;

i = 1;
for nseq = 1:nb_seq
    
    fprintf('Starting %i sequence \n', nseq);
    
    % load sequence
    fname = [set.sequences '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
    load(fname);
     
    % save all exposures
    nb_exp = seq.getExposureNb();
    for nexp = 1+skipFirst:nb_exp 
        
        % get exposure and mask
        [exp, mask, time_num] = seq.getExposure(nexp);
        time_str = cassis_num2time(time_num);
        fname_exp{i}  = [time_str '.tif']; 
        fname_mask{i} = [time_str '_mask.tif'];
        seq_list(i) = seqSummary.seq_list(nseq);
        t_list_{i} = time_str;
        exp_list(i) = nexp;
        exp_time(i) = seq.exposure_time;
         if islevel0
            exp = double(exp)*mult;
         end
        exp = flipud(exp);
        exp = imadjust(exp);
        
        % save exposure and mask
        imwrite(uint16(exp*2^16), [set.raw_exposures '/' fname_exp{i}]);
        imwrite((mask > 0), [set.raw_exposures '/' fname_mask{i}]);
        i = i + 1;
        
    end
    
end

% save exposure table
fname_exp = fname_exp';
fname_mask = fname_mask';
t_list_ = t_list_';
seq_list = seq_list';
exp_list = exp_list';
exp_time = exp_time';

expSummary = table(seq_list, exp_list, t_list_, exp_time, fname_exp, fname_mask);
writetable(expSummary, set.exposuresSummary); 

end

