%function SCRIPT_register_subExp(set)
clear all
addpath(genpath('../libraries'));

dataset_path = '/home/tulyakov/Desktop/espace-server/';
dataset_name = 'periapsis_orbit09';
set = DATASET_periapsisorb(dataset_path, dataset_name);

%%
% read dataset
clc
fprintf('Registering subexposures\n');

%%
% load sequences summary
seqSummary = readtable(set.sequencesSummary);
nb_seq = height(seqSummary);

%good_SubExp = {[2,3,4], [2 3 4], [2,3,4], [2,3,4], [1,2], [1, 2], [1, 2], [1, 2], [1], [1, 2, 3, 4], [1 2]};

subExps = {[1, 2, 3], [2, 3, 4], [2, 3, 4], [2, 3, 4], [1, 2], [1, 2], [1, 2], [1, 2], [1], [1, 2, 3, 4], [1, 2]}
%nimage = {2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1}
%subExps = {[2, 3, 4]};

f = figure;

%kernel_fname = '/HDD1/Data/CASSIS/2016_12_14_CASSIS_KERNELS/mk/em16_ops_v130_20161202_001.tm'
%cspice_furnsh(kernel_fname);

for nseq = 1:nb_seq
    
   % if( nseq == 9 )
   %     continue;
   % end
    
   fprintf('Sequence %s \n', [seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq}]);
   
   fname = [set.sequences '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
   load(fname);
 
 %%  
   %seq = seq.registerExp(subExps{nseq}, true);
   err = seq.estimateDistortion( subExps{nseq}, false)
      err_with = seq.estimateDistortion( subExps{nseq}, true)
      
   %%
   fname = [set.sequences '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
   save(fname, 'seq')
  
%     [georef_pano, Rgeo, Rmap, raw_pano, mask_pano] = expSeq.getImage(nimage{nseq});
%  figure(f);
%  georef_pano = im2uint16(georef_pano);
%  mapshow(georef_pano,Rmap);
%  xlabel('lon');
%  ylabel('lat');
%  
%  % save images for convenience
%  fname = [path 'browse_seq/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.eps'];
%  hgexport(f,fname)
%  
%  % save geotif
%  geotiffwrite([path 'browse_seq/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.tif'],...
%      georef_pano, Rgeo);
%  
%  % save raw data for "serious" work
%  fname = [path 'seq/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.png'];
%  imwrite(raw_pano, fname);
%  
%  % save raw mask for "serious" work
%  fname = [path 'seq/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '_mask.png'];
%  imwrite(mask_pano, fname);
%  
%  % add registration data to sequence and save sequence as well
%  fname = [path 'level1/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
%  save(fname, 'expSeq')
%  
end
