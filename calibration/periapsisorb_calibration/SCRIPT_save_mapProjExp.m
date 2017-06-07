% Script saves exposures (raw or map projected)

function SCRIPT_save_mapProjExp(set, prm)

%% params and dependencies
addpath(genpath('../libraries'));
mult = 1/(2^16-1); % 14bit images in 16bit

if ~exist('prm','var')
    prm.adjust_subExp_on = true;       % adjust intensity of sub exposures
    prm.corrLensDist_on  = false;     % correct distortions
end

fprintf('Saving map projected exposures for every sequence of %s dataset \n', set.name);

seqSummary = readtable(set.sequencesSummary);
nb_seq = height(seqSummary);

nexp_ttl = 1; % total number of exposures
f = figure();
for nseq = 1:nb_seq
    
    fname = [set.sequences '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
    load(fname);
     
    nb_exp = seq.getExpNb();
    for nExp = 1:nb_exp 
        
        fprintf('Starting %i sequence (i%), %i exposure (i%) \n', nseq, nb_seq, nExp, nb_exp);
        [exp_mapProj, mask_mapProj, Rmap] = seq.getMapProjExp( nExp, [1:seq.getSubExpNb()], prm.corrLensDist_on, prm.adjust_subExp_on);
        
        figure(f);
        exp_mapProj = im2uint16(exp_mapProj);
        mapshow(exp_mapProj, Rmap);
        xlabel('lon');
        ylabel('lat');

        time_num = seq.getExpTime(nExp);
        time_str = cassis_num2time(time_num);
                
        % save images for convenience
        fname = [set.mapProj_exposures '/' time_str '.png'];
        hgexport(f, fname,  ...
         hgexport('factorystyle'), 'Format', 'png'); 

        seq_list(nexp_ttl) = seqSummary.seq_list(nseq);
        exp_time{nexp_ttl} = time_str;
        exp_list(nexp_ttl) = nExp;
        exp_length(nexp_ttl) = seq.exp_length;
        nexp_ttl = nexp_ttl + 1;
        
    end
end

% save exposure table
exp_time = exp_time';
seq_list = seq_list';
exp_list = exp_list';
exp_length = exp_length';

expSummary = table(seq_list, exp_list, exp_time, exp_length);
writetable(expSummary, set.exposuresSummary); 

end

