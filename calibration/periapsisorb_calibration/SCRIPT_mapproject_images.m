function SCRIPT_mapproject_images(set)

%%
addpath(genpath('../libraries'));
corrLensDist_on = true;


%%

clc
fprintf('Map projecting images\n');

% load sequences summary
seqSummary = readtable(set.sequencesSummary);
nb_seq = height(seqSummary);

%good_SubExp = {[2,3,4], [2 3 4], [2,3,4], [2,3,4], [1,2], [1, 2], [1, 2], [1, 2], [1], [2, 3, 4], [1 2]};
%subExps = {[2, 3], [2, 3], [2, 3], [2, 3], [1, 2], [1, 2], [1,2], [1,2], [1], [1,2,3,4], [1,2]}
%nimage = {2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1}

f = figure;

%kernel_fname = '/HDD1/Data/CASSIS/2016_12_14_CASSIS_KERNELS/mk/em16_ops_v130_20161202_001.tm'
%cspice_furnsh(kernel_fname);

for nseq = 1:nb_seq
    
   fprintf('Sequence %s \n', [seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq}]);
   
   fname = [set.sequences '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
   load(fname);
   
 
  % corrLensDist_on = true;
   
   color = seq.getColor([2 3 4], corrLensDist_on);
  %  [image_pano2, mask_pano] = seq.getImage(3, corrLensDist_on);
  %  [image_pano3, mask_pano] = seq.getImage(4, corrLensDist_on);

    %[optimizer,metric] = imregconfig('monomodal');
    %image_pano2_ = imregister(image_pano2, image_pano1, 'translation', optimizer, metric);
    %image_pano3_ = imregister(image_pano3, image_pano1, 'translation', optimizer, metric);

    %color = cat(3,image_pano1,image_pano2,image_pano3);
  %   color = cat(3,image_pano1,image_pano2,image_pano3);

    imwrite(uint8(color*256),'pointing_corr.png');

 %   A = [[-0.6106, -0.5445, -0.0015, 0.9998, 0.0002, 0];
 %   [-0.0049, -0.607, -0.5433, -0.0005, 0.9943, 0.0005];
 %   [-0.0496, -0.0257, -0.0703, -0.6092, -0.5101, 1]];
 %   seq = setLensDistortion(seq, A);

 
 % [exp, mask, time, lon, lat] = expSeq.getFrame(1, [1,2,3,4])
 
 %   seq = seq.registerExp(good_SubExp{nseq});

  
 
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
