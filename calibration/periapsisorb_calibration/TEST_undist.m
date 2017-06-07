addpath(genpath('../libraries'));

dataset_path = '/home/tulyakov/Desktop/espace-server/';
dataset_name = 'periapsis_orbit09';
set = DATASET_periapsisorb(dataset_path, dataset_name);

lensDistortion = readtable(set.lensDistortion_final);
A = [lensDistortion.A_1 lensDistortion.A_2 lensDistortion.A_3 lensDistortion.A_4 lensDistortion.A_5 lensDistortion.A_6];

load('2016-11-22T16.01.10.635~2016-11-22T16.03.06.635.mat')

seq = seq.setLensDistortion(A);


corrLensDist_on = false;
   
[image_pano1, mask_pano] = seq.getImage(2, corrLensDist_on);
%[image_pano2, mask_pano] = seq.getImage(3, corrLensDist_on);
%[image_pano3, mask_pano] = seq.getImage(4, corrLensDist_on);
%color = cat(3,image_pano1,image_pano2,image_pano3);

imwrite(uint8(color*256),'image_dist.png');

%[image_pano, mask_pano] = seq.getColor([1 2 3], corrLensDist_on);
% corrLensDist_on = true;
% virtualImage_on = true;
% adjustSubExp_on = true;
% image = seq.getExp(5, [1 2 3 4], corrLensDist_on, virtualImage_on, adjustSubExp_on);
%  
% imwrite(image,'full_exp_undist.png');