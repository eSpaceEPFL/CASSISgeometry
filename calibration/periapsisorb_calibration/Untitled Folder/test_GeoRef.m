
clear all; close all;


kernel_fname = '/HDD1/Data/CASSIS/2016_12_14_CASSIS_KERNELS/mk/em16_ops_v130_20161202_001.tm'
seq_fname = '/HDD1/Data/CASSIS/2016_11_01_MARS/level1/2016-11-22T16.01.10.635~2016-11-22T16.03.06.635.mat'

load(seq_fname)
[frame, mask, timenum] = expSeq.getFrame(3, [1 2 3 4]);

imshow(frame)

w = expSeq.refFrame_xywh{2}(:,3)
h = expSeq.refFrame_xywh{2}(:,4);
x11 = expSeq.refFrame_xywh{2}(:,1);
y11 = expSeq.refFrame_xywh{2}(:,2);
x_win = [x11 x11   x11+w x11+w];
y_win = [y11 y11+h y11   y11+h];
            
cspice_furnsh(kernel_fname);

x= [1 2048 1    2048];
y= [1 1    2048 2048];

[lat, lon] = getPixLatLon(x, y, timenum);

[lat_win, lon_win] = getPixLatLon(x_win, y_win, timenum);


