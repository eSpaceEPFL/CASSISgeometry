%% param


clear all;
close all;

% 2016-11-22T16.10.21.006~2016-11-22T16.11.04.505.mat
% 20

addpath(genpath('../mice'));
seq_fname = '/HDD1/Data/CASSIS/2016_11_01_MARS/level1/2016-11-22T16.18.05.673~2016-11-22T16.18.25.974.mat'
load(seq_fname)

kernel_fname = '/HDD1/Data/CASSIS/2016_12_14_CASSIS_KERNELS/mk/em16_ops_v130_20161202_001.tm'
cspice_furnsh(kernel_fname);

[frame, mask, time, lon, lat] = expSeq.getFrame(20, [1 2]);
      
figure; imshow(frame)
