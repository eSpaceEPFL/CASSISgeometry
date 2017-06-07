function seq_list = cassis_recognize_seq(t_list, exp_list)

% Finds sequence number for each package

nb_time = length(t_list);
[~, ind] = sort(t_list, 'ascend'); 
exp_sort = exp(exp_list);
nseq = 0;

for ntime = 1:nb_time
    
    if( ntime >= 2 )
        if( exp_sort(ntime) < exp_sort(ntime-1) )
            nseq = nseq + 1;
        end 
    end
    seq_list(ntime) = nseq;
    
end