function SCRIPT_add_cam_param(set)

addpath(genpath('../libraries'));
dataset_path = '/home/tulyakov/Desktop/espace-server/';
dataset_name = 'periapsis_orbit09';
set = DATASET_periapsisorb(dataset_path, dataset_name);

%%
clc
fprintf('Adding camera parameters to sequences\n');

% load sequences summary
seqSummary = readtable(set.sequencesSummary);
nb_seq = height(seqSummary);

%% read intrinsics
intrinsic = readtable(set.intrinsic_final); 
x0 = intrinsic.x0;
y0 = intrinsic.y0;
pixSize = intrinsic.pixSize;
f = intrinsic.f;
K = f_x0_y0_2K(f, x0, y0, pixSize);

%% read lens distortion
lensDistortion = readtable(set.lensDistortion_final);
A = [lensDistortion.A_1 lensDistortion.A_2 lensDistortion.A_3 lensDistortion.A_4 lensDistortion.A_5 lensDistortion.A_6];

%% read rotation commands

%% read spice extrinsic parameters

%% read systematic rotation error correction


for nseq = 1:nb_seq
   
    fprintf('Sequence %s \n', [seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq}]);
    
    fname = [set.sequences '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
    load(fname);
        
    seq = seq.setLensDistortion(A);
    seq = seq.setIntrinsics(f, x0, y0, pixSize);
    
    % add registration data to sequence and save sequence as well
    fname = [set.sequences '/' seqSummary.start_time{nseq} '~' seqSummary.finish_time{nseq} '.mat'];
    save(fname, 'seq')
    
end
