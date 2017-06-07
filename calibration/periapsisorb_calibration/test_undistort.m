clear all;
load('/home/tulyakov/Desktop/espace-server/CASSIS/aerobraking/161126_periapsis_orbit10/OUTPUT/sequences/2016-11-26T22.32.14.582~2016-11-26T22.32.53.582.mat')


correct_on = true;


A = [[-0.6106, -0.5445, -0.0015, 0.9998, 0.0002, 0];
    [-0.0049, -0.607, -0.5433, -0.0005, 0.9943, 0.0005];
    [-0.0496, -0.0257, -0.0703, -0.6092, -0.5101, 1]];

seq = setLensDistortion(seq, A);


% corrLensDist_on = false;
% virtualImage_on = true;
% adjustSubExp_on = true;
% [exp, mask] = seq.getExp( 1, corrLensDist_on, virtualImage_on, adjustSubExp_on );
% corrLensDist_on = true;
% [exp_corr, mask_corr] = seq.getExp( 1, corrLensDist_on, virtualImage_on, adjustSubExp_on );

   
[image_pano, mask_pano] = seq.getImage(2, corrLensDist_on);
   
%[framelet, mask] = seq.getFramelet(2, 2, correct_on);
