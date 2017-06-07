clear all;
close all;

path = '/HDD1/Data/CASSIS/2016_11_01_MARS'
left_fname = [path '/seq/2016-11-22T16.21.48.394~2016-11-22T16.21.59.994_raw.png'];
right_fname = [path '/seq/2016-11-22T16.22.40.040~2016-11-22T16.22.50.190_raw.png'];

frame1 = flip(flip(imread(left_fname)',1),2);
frame2 = imread(right_fname)';

multibandwrite(frame1, [ path '/stereo/' sprintf('frame1_%ix%i.raw', size(frame1,1), size(frame1,2))], 'bsq', [1 1 1], [size(frame1) 1]);
multibandwrite(frame2, [ path '/stereo/' sprintf('frame2_%ix%i.raw', size(frame2,1), size(frame2,2))], 'bsq', [1 1 1], [size(frame2) 1]);
       
