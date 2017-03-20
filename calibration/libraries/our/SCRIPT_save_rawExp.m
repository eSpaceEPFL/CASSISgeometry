% Script flattens images, substracts dark field, masks out problems

function SCRIPT_save_rawExp(set, prm)

%% params and dependencies

addpath(genpath('../libraries'));
mult = 1/(2^16-1); % 14bit images in 16bit

if ~exist('prm','var')
    prm.skip_first_exp = 2;
    prm.adjust_subExp_on = false;
end

fprintf('Saving individual exposures for every sequence of %s dataset \n', set.name);

% load sequences summary
seqSummary = readtable(set.sequencesSummary);
nb_seq = height(seqSummary);
%f = figure;

i = 1;
for nseq = 1:nb_seq
    
    fprintf('Starting %i sequence \n', nseq);
    
    % load sequence
    fname = [set.sequences '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
    load(fname);
     
    % save all exposures
    nb_exp = seq.getExpNb();
    for nExp = 1+prm.skip_first_exp:nb_exp 
        
        % get exposure and mask
        corrLensDist_on = false;
        virtualImage_on = true;
        %adjustSubExp_on = false;
        
        [exp, mask] = seq.getExp(nExp, [1:seq.getSubExpNb], corrLensDist_on, virtualImage_on, prm.adjust_subExp_on);
        
        time_num = seq.getExpTime(nExp);
        
        time_str = cassis_num2time(time_num);
        fname_exp{i}  = [time_str '.tif']; 
        fname_mask{i} = [time_str '_mask.tif'];
        seq_list(i) = seqSummary.seq_list(nseq);
        exp_time{i} = time_str;
        exp_list(i) = nExp;
        exp_length(i) = seq.exp_length;
        
        if isfield(set, 'level0')
            exp = double(exp)*mult;
        end

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
exp_time = exp_time';
seq_list = seq_list';
exp_list = exp_list';
exp_length = exp_length';

expSummary = table(seq_list, exp_list, exp_time, exp_length, fname_exp, fname_mask);
writetable(expSummary, set.exposuresSummary); 

end
