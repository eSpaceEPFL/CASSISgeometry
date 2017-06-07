%function SCRIPT_save_images(set)

addpath(genpath('../libraries'));

dataset_path = '/home/tulyakov/Desktop/espace-server/';
dataset_name = 'periapsis_orbit09';
set = DATASET_periapsisorb(dataset_path, dataset_name);
corrLensDist_on = false;
cspice_furnsh(set.spice);

%%
clc
fprintf('Saving sequence images\n');

%%
% load sequences summary
seqSummary = readtable(set.sequencesSummary);
nb_seq = height(seqSummary);

%good_SubExp = {[2,3,4], [2 3 4], [2,3,4], [2,3,4], [1,2], [1, 2], [1, 2], [1, 2], [1], [2, 3, 4], [1 2]};
%subExps = {[2, 3], [2, 3], [2, 3], [2, 3], [1, 2], [1, 2], [1,2], [1,2], [1], [1,2,3,4], [1,2]}
%nimage = {2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1}

visExp = {[2, 2, 2], [2, 3, 4], [2, 3, 4], [2, 3, 4], [1, 2, 2], [1, 2, 2], [1, 2, 2], [1, 2, 2], [1, 1, 1], [2, 3, 4], [1 2 2]};
f = figure;

for nseq = 1:nb_seq
    
      
   fprintf('Sequence %s \n', [seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq}]);
   
   fname = [set.sequences '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
   load(fname);
 
   color = seq.getColor(visExp{nseq}, corrLensDist_on);

  % save images for convenience
  if ~corrLensDist_on
    fname = [set.colorMosaic_dist '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '_dist.png'];
  else
    fname = [set.colorMosaic_undist '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '_undist.png'];
  end
  imwrite(color, fname);
  figure(f);imshow(color);  
  
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
