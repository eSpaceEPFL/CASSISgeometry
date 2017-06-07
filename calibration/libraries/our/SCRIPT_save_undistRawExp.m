% Script saves exposures (raw or map projected)

function SCRIPT_save_rawExp(set, prm)

%% params and dependencies
addpath(genpath('../libraries'));
mult = 1/(2^16-1); % 14bit images in 16bit

if ~exist('prm','var')
    prm.skip_first_exp = 2;             % how many first exposures to skip
    prm.adjust_subExp_on = false;       % adjust intensity of sub exposures
    prm.virtualImage_on = true;         % save virtual image
end

fprintf('Saving individual exposures for every sequence of %s dataset \n', set.name);

seqSummary = readtable(set.sequencesSummary);
nb_seq = height(seqSummary);

nexp_ttl = 1; % total number of exposures
for nseq = 1:nb_seq
    
    fprintf('Starting %i sequence \n', nseq);
    
    fname = [set.sequences '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
    load(fname);
     
    nb_exp = seq.getExpNb();
    for nExp = 1+prm.skip_first_exp:nb_exp 
        
        [exp, mask] = seq.getExp(nExp, [1:seq.getSubExpNb()], true, prm.virtualImage_on, prm.adjust_subExp_on);
        
        time_num = seq.getExpTime(nExp);
        time_str = cassis_num2time(time_num);
        
        fname_exp{nexp_ttl}  = [time_str '.tif']; 
        fname_mask{nexp_ttl} = [time_str '_mask.tif'];
        seq_list(nexp_ttl) = seqSummary.seq_list(nseq);
        exp_time{nexp_ttl} = time_str;
        exp_list(nexp_ttl) = nExp;
        exp_length(nexp_ttl) = seq.exp_length;
        
        if isfield(set, 'level0')
            exp = double(exp)*mult;
        end

        exp = imadjust(exp);
        
        % save exposure and mask
        imwrite(uint16(exp*2^16), [set.undist_raw_exposures '/' fname_exp{nexp_ttl}]);
        imwrite((mask > 0), [set.undist_raw_exposures '/' fname_mask{nexp_ttl}]);
        nexp_ttl = nexp_ttl + 1;
        
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

