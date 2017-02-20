path = '/HDD1/Data/CASSIS/2016_11_01_MARS'
im_fname = [path '/seq/2016-11-22T16.21.48.394~2016-11-22T16.21.59.994_raw.png'];
disp_fname = [path '/stereo/disp.tif']; 

im = flip(flip(imread(im_fname)',1),2);;
disp = imread(disp_fname);

mask = (disp(:,:,3));
map = (disp(:,:,1));
map(~mask) = inf;
[Isub, plane] = substractPlane(map);
%im(~mask) = inf;


% make mesh 
[X,Y ] = meshgrid(1:50:size(im,2), 1:50:size(im,1));
I = sub2ind(size(im),Y,X);
valid = mask(I) ~= 0;
X=X;
Y=Y;
Z = medfilt2(120-Isub(I),[5,5]);


% colormap(map)
% surface(X,Y,Z, 'FaceColor','texturemap',...
% 'EdgeColor','none','Cdata',im)
% mesh(X,Y,Z);

warp(X,Y,Z, im)
 

imshow(im);
figure;imagesc(Isub,[-110 125])
