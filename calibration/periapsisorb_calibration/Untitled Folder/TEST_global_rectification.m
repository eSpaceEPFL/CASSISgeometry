%% param


clear all;
close all;

left_fname = '/HDD1/Data/CASSIS/2016_11_01_MARS/seq/2016-11-22T16.21.48.394~2016-11-22T16.21.59.994_raw.png'
right_fname = '/HDD1/Data/CASSIS/2016_11_01_MARS/seq/2016-11-22T16.22.40.040~2016-11-22T16.22.50.190_raw.png'

frame1= flip(flip(imread(left_fname)',1),2);
frame2 = imread(right_fname)';
       

 th = 1000;
 pts1 = detectSURFFeatures(frame1,'MetricThreshold',th);
 pts2 = detectSURFFeatures(frame2,'MetricThreshold',th);
 
 [features1,  validPts1]  = extractFeatures(frame1,  pts1);
 [features2, validPts2]  = extractFeatures(frame2, pts2);
 
 indexPairs = matchFeatures(features1, features2);
 
 matchedPoints1 = validPts1(indexPairs(:,1),:);
 matchedPoints2 = validPts2(indexPairs(:,2),:);
 
 rectifier = class_rectifier(frame1, frame2, matchedPoints1.Location, matchedPoints2.Location);
 rectifier = estimateRectificationTransform(rectifier);
 [xRange, yRange] = estimateRectifiedDisparityRange(rectifier);
 [mRectI, sRectI] = rectifyImages(rectifier);
 
 load('best_param.mat');
 prm = best_prm;
 % prm.cbca1=0;
           % prm.cbca2=0;
            prm.nb_disp = ceil(xRange(2)-xRange(1)+1);
            prm.min_disp = floor(xRange(1));
    [mRectDisp, mRectMask] = mei_stereo_cuda(mRectI(1500:2000,:), (mRectI(1500:2000,:)~=0), sRectI(1500:2000,:), (sRectI(1500:2000,:)~=0), prm);
 
 
 [mHeight, mWidth] = size(mRectI);
 [sHeight, sWidth] = size(sRectI);
 dispMin = round(xRange(1))-100; 
 commonWidth = min(min(mWidth-dispMin, sWidth-dispMin),2000);
  
 sRectI_ = imcrop(sRectI, [dispMin+1, 1, commonWidth, mHeight]);  
 mRectI_ = imcrop(mRectI, [1, 1, commonWidth, sHeight]);  
 