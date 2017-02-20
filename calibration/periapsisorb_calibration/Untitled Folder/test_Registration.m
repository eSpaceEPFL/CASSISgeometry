clear all; close all;

im = rgb2gray(imread('peppers.png'));
tile1 = im(1:40,:);
tile2 = im(10:50,:);


[optimizer,metric] = imregconfig('monomodal');
tform0 = affine2d([1 0 0; 0 1 0; 0 10 1]);

movingRegisteredRigid = imwarp(tile1,tform0,'OutputView',imref2d(size(tile1)));

figure, imshowpair(movingRegisteredRigid, tile2);

movingRegisteredDefault = imregtform(tile1, tile2, 'translation', optimizer, metric,'InitialTransformation',tform0);

figure, imshowpair(movingRegisteredDefault, tile2, 'montage')