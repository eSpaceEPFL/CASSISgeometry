clear all;
close all;

%% param
path = '/HDD1/Data/CASSIS/2016_11_01_MARS/';


%%
% load sequences summary
seqSummary = readtable([path 'level1/seq_summary.csv']);
seqSubexp = {[2, 3], [2, 3], [2, 3], [2, 3], [1, 2], [1, 2], [1,2], [1,2], [1], [1,2,3,4], [1,2]}   
nimage = {2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1}

nb_seq = height(seqSummary);
f = figure;

kernel_fname = '/HDD1/Data/CASSIS/2016_12_14_CASSIS_KERNELS/mk/em16_ops_v130_20161202_001.tm'
cspice_furnsh(kernel_fname);

for nseq = 1:nb_seq
    if( nseq == 9 )
        continue;
    end
    
    fname = [path 'level1/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
    load(fname)
    
    
   % [exp, mask, time, lon, lat] = expSeq.getFrame(1, [1,2,3,4])
    
    expSeq = expSeq.registerFramelets(seqSubexp{nseq});
    [georef_pano, Rgeo, Rmap, raw_pano, mask_pano] = expSeq.getImage(nimage{nseq});
    figure(f); 
    georef_pano = im2uint16(georef_pano);
    mapshow(georef_pano,Rmap);
    xlabel('lon');
    ylabel('lat');
    
    % save images for convenience 
    fname = [path 'browse_seq/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.eps'];
    hgexport(f,fname)
    
    % save geotif
    geotiffwrite([path 'browse_seq/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.tif'],...
    georef_pano, Rgeo);
        
    % save raw data for "serious" work
    fname = [path 'seq/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.png'];
    imwrite(raw_pano, fname);
    
    % save raw mask for "serious" work
    fname = [path 'seq/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '_mask.png'];
    imwrite(mask_pano, fname);
        
    % add registration data to sequence and save sequence as well
    fname = [path 'level1/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
    save(fname, 'expSeq')

end
