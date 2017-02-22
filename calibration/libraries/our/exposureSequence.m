classdef exposureSequence
   properties
       % all framelets are saved in hronological order
       % we assume that all framelets have same : 
       % *size
       % *exposure_time
       % *position in frame
       image_size = [2048 2048];
       corr2distA
       dist2corrA
       time      % time(nExp)
       framelet  % {nSubExp}(:,:,nExp)
       exposure_time  
       refFrame_xywh  % {nSubExp} position of framelet in frame
       dx  % position of framelet in image
       dy
   end
   methods
       
      
%      function obj = setCameraParameters(obj, lensDistortion_fname)
%             lensDistortion = readtable(lensDistortion_fname);
%             obj.A = [lensDistortion.A_1 lensDistortion.A_2 lensDistortion.A_3 
%                       lensDistortion.A_4 lensDistortion.A_5 lensDistortion.A_6];
%      end
       
      function obj = exposureSequence(path, fname_list, islevel0)
       
          % 'float=>float' for level 1
          % 'uint16=>uint16' for level 0
          
          % read all files and save
          for i = 1:length(fname_list)
              
              fname = [path '/' fname_list{i}];
              
              [~, tmp, nExp, nSubExp] = cassis_parse_filename(fname_list{i});  
              nExp = nExp + 1;
              nSubExp = nSubExp + 1;
              obj.time(nExp) = cassis_time2num(tmp);
              
              if islevel0
                [obj.framelet{nSubExp}(:,:,nExp), obj.refFrame_xywh{nSubExp}, obj.exposure_time] = cassis_read_subexp(fname, 'uint16=>uint16');  
              else
                [obj.framelet{nSubExp}(:,:,nExp), obj.refFrame_xywh{nSubExp}, obj.exposure_time] = cassis_read_subexp(fname, 'float=>float');  
              end
                                          
          end
  
      end
      
      function nb_exp = getExposureNb(obj) 
          
        nb_exp = length(obj.time);
        
      end
      
      function [exp, mask] = getExp(obj, nExp, corrLensDist_on, virtualImage_on, adjustSubExp_on, subExps)
          
          mask = false(obj.image_size); 
          exp = zeros(obj.image_size);
          
          if ~exist('subExps','var')
              subExps = 1:length(obj.framelet);
          end
          
          for i = 1:length(subExps)
              nSubExp = subExps(i);              
              
              [x0,y0,w,h] = obj.getSubExpBound(nSubExp);
               
              exp(y0:y0+h-1, x0:x0+w-1) = obj.getSubExp(nSubExp, nExp, false); 
              mask(y0:y0+h-1, x0:x0+w-1) = true; 
          
              if adjustSubExp_on
                  
                  exp(y0:y0+h-1, x0:x0+w-1) = imadjust(exp(y0:y0+h-1, x0:x0+w-1));
              
              end
          end 
          
          if corrLensDist_on
              
              % sensor coordinates
              [x_sensor, y_sensor] = meshgrid(1:size(exp,2), 1:size(exp,1));
                            
              % sensor-2-frontal focal plane coordinates
              [x_front, y_front] = cassis_sensor2front(x_sensor, y_sensor, obj.image_size(1));
              
              % normalize
              xx = [x_front(:) y_front(:)];
              xx_norm = pixel2norm(xx, obj.image_size);
              chi = lift2D_to_6D(xx_norm);
              
              % distort
              ij_norm = chi*obj.corr2distA';
              ij_norm(:,1) = ij_norm(:,1)./ij_norm(:,3);
              ij_norm(:,2) = ij_norm(:,2)./ij_norm(:,3);
              ij_norm = ij_norm(:,[1 2]);
              
              % denormalize
              ij = norm2pixel(ij_norm, obj.image_size);
              
              % frontal focal plane coordinates-2-sensor
              [i_front, j_front] = deal(ij(:,1), ij(:,2));
              i_front = reshape(i_front, size(x_front));
              j_front = reshape(j_front, size(x_front));
              
              [i_sensor, j_sensor] = cassis_front2sensor(i_front, j_front, obj.image_size(1));
                            
              % interpolate
              exp = interp2(x_sensor, y_sensor, exp, i_sensor, j_sensor);
              mask = ~isnan(exp) & mask ;
              exp(~mask) = 0;
              
          end
          
          if virtualImage_on
                
              exp = flipud(exp);
              mask = flipud(mask);
                            
          end
          
      end
          
          % get coordinates of framelet border for georeferencing
%          w = 2048;
%          h = 2048;
%          x11 = 1;
%          y11 = 1;
%          x_framelet = [x11 x11   x11+w x11+w];
%          y_framelet = [y11 y11+h y11   y11+h];
%          [lat, lon] = getPixLatLon(x_framelet, y_framelet, obj.time(nExp));
          
%           tform = fitgeotrans([x_framelet(:) y_framelet(:)], [lon(:) lat(:)],'projective');
%           
%           mInput = size(exp,1);
%           nInput = size(exp,2);
%           
%           inputCorners = 0.5 ...
%               + [0        0;
%               0        mInput;
%               nInput   mInput;
%               nInput   0;
%               0        0];
%           
%           outputCornersSpatial = transformPointsForward(tform, inputCorners);
%           
%           outputCornersLon = outputCornersSpatial(:,1);
%           outputCornersLat = outputCornersSpatial(:,2);
%           
%           pixelSize = [hypot( ...
%               outputCornersLon(2) - outputCornersLon(1), ...
%               outputCornersLat(2) - outputCornersLat(1)) / mInput, ...
%               hypot( ...
%               outputCornersLon(4) - outputCornersLon(5), ...
%               outputCornersLat(4) - outputCornersLat(5)) / nInput];
%           
%           outputPixelSize  = max(pixelSize);
%           
%           lonWorldLimits = outputPixelSize ...
%               * [floor(min(outputCornersLon) / outputPixelSize), ...
%               ceil(max(outputCornersLon) / outputPixelSize)];
%           
%           latWorldLimits = outputPixelSize ...
%               * [floor(min(outputCornersLat) / outputPixelSize), ...
%               ceil(max(outputCornersLat) / outputPixelSize)];
%           
%           mOutput = round(diff(latWorldLimits) / outputPixelSize);
%           nOutput = round(diff(lonWorldLimits) / outputPixelSize);
%           %residuals = transformPointsForward(tform, [x_pano(:) y_pano(:)]) - [lon_pano(:) lat_pano(:)];
%           
%           R = imref2d([mOutput nOutput],lonWorldLimits,latWorldLimits);
%           
%           
%           if latWorldLimits(1) < latWorldLimits(2)
%               if lonWorldLimits(1) < lonWorldLimits(2)
%                   exp = flipud(imwarp(exp, tform, 'OutputView', R));
%               else
%                   exp = fliprl(flipud(imwarp(exp, tform, 'OutputView', R)));
%               end
%           else
%               if lonWorldLimits(1) < lonWorldLimits(2)
%                   exp = (imwarp(image_pano, tform, 'OutputView', R));
%               else
%                   exp = fliprl((imwarp(exp, tform, 'OutputView', R)));
%               end
%           end
%           
%           
%           Rgeo = georasterref('RasterSize',R.ImageSize, ...
%               'LatitudeLimits',latWorldLimits,'LongitudeLimits',lonWorldLimits, 'ColumnsStartFrom','north');
%           
%           Rmap = maprasterref('RasterSize',R.ImageSize, ...
%               'YWorldLimits',R.YWorldLimits,'XWorldLimits',R.XWorldLimits, 'ColumnsStartFrom','north');
%           
%            figure; 
%             exp = im2uint16(exp);
%             mapshow(exp,Rmap);
%             xlabel('lon');
%             ylabel('lat');deLimits',latWorldLimits,'LongitudeLimits',lonWorldLimits, 'ColumnsStartFrom','north');
%           
%           Rmap = maprasterref('RasterSize',R.ImageSize, ...
%               'YWorldLimits',R.YWorldLimits,'XWorldLimits',R.XWorldLimits, 'ColumnsStartFrom','north');
%           
%            figure; 
%             exp = im2uint16(exp);
%             mapshow(exp,Rmap);
%             xlabel('lon');
%             ylabel('lat');
          
%      end
      
               
      function obj = registerExp(obj, subExps)
         
         diff(1,:) = [0, 0];
         
         nbExp = length(obj.time);
         
         for nExp = 1:nbExp-1
             
             % reconstruct frames
             corrLensDist_on = true;
             virtualImage_on = true;
             adjustSubExp_on = true;
             [exp1, mask] = obj.getExp(nExp, corrLensDist_on, virtualImage_on, adjustSubExp_on, subExps);
             [exp2, ~] = obj.getExp(nExp+1, corrLensDist_on, virtualImage_on, adjustSubExp_on, subExps);
             
             % get features
             th = 1000;
             pts1 = detectSURFFeatures(exp1,'MetricThreshold',th);
             pts2 = detectSURFFeatures(exp2,'MetricThreshold',th);
             [features1,  validPts1]  = extractFeatures(exp1,  pts1);
             [features2, validPts2]  = extractFeatures(exp2, pts2);
             
             % eliminate points that are close to mask
             mask = imerode(mask, ones(10));
             
             x1 = max(min(round(validPts1.Location(:,1)),2048),1);
             y1 = max(min(round(validPts1.Location(:,2)),2048),1);
             valid1 = mask(sub2ind(size(mask), x1, y1));
             
             x2 = max(min(round(validPts2.Location(:,1)),2048),1);
             y2 = max(min(round(validPts2.Location(:,2)),2048),1);
             valid2 = mask(sub2ind(size(mask), x2, y2));
             
             features1 = features1(valid1,:);
             validPts1 = validPts1(valid1);
             
             features2 = features2(valid2,:);
             validPts2 = validPts2(valid2);
             
             % match features
             indexPairs = matchFeatures(features1, features2);
             [tformTotal,~,~,status] = estimateGeometricTransform(validPts2(indexPairs(:,2)),...
                 validPts1(indexPairs(:,1)),'similarity');
             
             if status == 0
                 diff(nExp+1,:) = [tformTotal.T(3,1) tformTotal.T(3,2)];
             else
                 diff(nExp+1,:) = [nan nan];
             end
         end
         
         % fit shifts (assume that they changes linearly from exposure to
         % exposure)
         b = robustfit([1:length(obj.time)-1], diff(2:end,1));
         diff(2:end,1) = b(1) + b(2)*[1:length(obj.time)-1];

         b = robustfit([1:length(obj.time)-1], diff(2:end,2));
         diff(2:end,2) = b(1) + b(2)*[1:length(obj.time)-1];
         
         obj.dx = cumsum(diff(:,1));
         obj.dy = cumsum(diff(:,2));
         
      end
   

      
%      function [lat, lon] = getSubexpLonLat(obj, x, y, kernel_fname)
%                   
%          blender = vision.AlphaBlender('Operation', 'Binary mask', ...
%     'MaskSource', 'Input port'); 
%           
%          % find image size 
%          x_max = max(obj.dx+obj.refFrame_xywh{nSubExp}(:,3));
%          x_min = min(obj.dx+1);
% 
%          y_max = max(obj.dy+obj.refFrame_xywh{nSubExp}(:,4));
%          y_min = min(obj.dy+1);
%          
%          width  = ceil(x  [lat_framelet, lon_framelet] = getPixLatLon(x_framelet, y_framelet, obj.time(i));_max - x_min + 1);
%          height = ceil(y_max - y_min + 1);
%          
%          image_pano = zeros(height, width);
%          expID_pano = zeros(height, width);
%          
%          xLimits = [x_min x_max];
%          yLimits = [y_min y_max];
%          
%          panoramaView = imref2d([height width], xLimits, yLimits);
%         
%          % find optimal intensity limits
%          lim = stretchlim(obj.framelet{nSubExp}(:));
%                   
%          % Create the panorama.
%          for i = 1:length(obj.time)
%             
%             tform = affine2d([1 0 0; 0 1 0; obj.dx(i) obj.dy(i) 1]);
%             
%             framelet = imadjust(double(obj.framelet{nSubExp}(:,:,i)),lim);
%             warpedImage = imwarp(framelet, tform, 'OutputView', panoramaView);
% 
%             % Generate a binary mask.
%             mask = imwarp(true(size(framelet,1),size(framelet,2)), tform, 'OutputView', panoramaView);
% 
%             % Overlay the warpedImage onto the panorama.
%             image_pano = step(blender, image_pano, warpedImage, mask);
%             expID_pano = step(blender, expID_pano, i*double(mask), mask);
%             
%          end
%          
%          expID_pano = uint8(expID_pano);
%       
%       end
%    
     
      function obj = setLensDistortion(obj, dist2corrA)
            
          % distorted-2-undistorted
          obj.dist2corrA = dist2corrA; 
          
          % undistorted-2-distorted
          [obj.corr2distA, maxErr] = inverse_rational_model(dist2corrA, obj.image_size);
          if( maxErr > 3e-2)
            warning('Error of the inverse rational model is too high!');
          end
          
      end
        
      function [x,y,w,h] = getSubExpBound(obj, nSubExp)
         [x,y,w,h] = deal(obj.refFrame_xywh{nSubExp}(1), obj.refFrame_xywh{nSubExp}(2),...
                     obj.refFrame_xywh{nSubExp}(3), obj.refFrame_xywh{nSubExp}(4));
      end
      
      function time = getExpTime(obj, nExp)
         time = obj.time(nExp);
      end
      
      function [subExp, mask] = getSubExp(obj, nSubExp, nExp, correct_on)
         
          subExp = obj.framelet{nSubExp}(:,:,nExp);
          mask = true(size(subExp));
          
          % correct distortion
          if( correct_on ) 
                
              [xmin, ymin, ~, ~] = getSubExpBound(obj, nSubExp);
              %xmin = obj.refFrame_xywh{nSubExp}(1);
              %ymin = obj.refFrame_xywh{nSubExp}(2);
                            
              % subexposure coordinates
              [x_subExp, y_subExp] = meshgrid(1:size(subExp,2), 1:size(subExp,1));
              
              % subexposure-2-sensor coordinates
              [x_sensor, y_sensor] = cassis_subexp2sensor(x_subExp, y_subExp, xmin, ymin);
              
              % sensor-2-frontal focal plane coordinates
              [x_front, y_front] = cassis_sensor2front(x_sensor, y_sensor, obj.image_size(1));
    
              % normalize
              xx = [x_front(:) y_front(:)];
              xx_norm = pixel2norm(xx, obj.image_size);
              chi = lift2D_to_6D(xx_norm); 

              % distort
              ij_norm = chi*obj.corr2distA';
              ij_norm(:,1) = ij_norm(:,1)./ij_norm(:,3);
              ij_norm(:,2) = ij_norm(:,2)./ij_norm(:,3);
              ij_norm = ij_norm(:,[1 2]);    
              
              % denormalize
              ij = norm2pixel(ij_norm, obj.image_size);
              
              % frontal focal plane coordinates-2-sensor
              [i_front, j_front] = deal(ij(:,1), ij(:,2));
              i_front = reshape(i_front, size(x_front));
              j_front = reshape(j_front, size(x_front));
              
              [i_sensor, j_sensor] = cassis_front2sensor(i_front, j_front, obj.image_size(1));  
                
              % sensor-2-subexposure
              [i_subExp, j_subExp] = cassis_sensor2subexp(i_sensor, j_sensor,  xmin, ymin);
              
              % interpolate
              subExp = interp2(x_subExp, y_subExp, subExposure, i_subExp, j_subExp);
              mask = ~isnan(subExp);
              subExp(~mask) = 0;
          end
                    
      end
      
      function [image, mask] = getImage(obj, nSubExp)
                
            
         blender = vision.AlphaBlender('Operation', 'Binary mask', ...
        'MaskSource', 'Input port'); 

         % find panorama size 
         x_max = max(obj.dx+obj.refFrame_xywh{nSubExp}(:,3));
         x_min = min(obj.dx+1);

         y_max = max(obj.dy+obj.refFrame_xywh{nSubExp}(:,4));
         y_min = min(obj.dy+1);
         
         width  = ceil(x_max - x_min + 1);
         height = ceil(y_max - y_min + 1);
         
         image_pano = zeros(height, width);
         mask_pano = zeros(height, width);
         
         xLimits = [x_min x_max];
         yLimits = [y_min y_max];
         
         panoramaView = imref2d([height width], xLimits, yLimits);
        
         % find optimal intensity limits
         lim = stretchlim(obj.framelet{nSubExp}(:));
                  
         % create the panorama by adressing one framelet at the time.
         x_pano =[];
         y_pano = [];
         lat_pano = [];
         lon_pano = [];
         
         for i = 1:length(obj.time)
            
             % define transformation
             tform = affine2d([1 0 0; 0 1 0; obj.dx(i) obj.dy(i) 1]);
             
             % compute coordinates of the framelet in pano
             [x_framelet_pano, y_framelet_pano] = transformPointsForward(tform, x_framelet, y_framelet);
             x_pano = [x_pano;x_framelet_pano];
             y_pano = [y_pano;y_framelet_pano];
                          
             [subExp, mask] = obj.getSubExp(nSubExp, nExp, correct_on);
             
             framelet = imadjust(double(obj.framelet{nSubExp}(:,:,i)),lim);
              
             warpedImage = imwarp(framelet, tform, 'OutputView', panoramaView);
             
            % Generate a binary mask.
             mask = imwarp(true(size(framelet,1),size(framelet,2)), tform, 'OutputView', panoramaView);
          %  opacity = zeros(size(image_pano));
          %   opacity(mask) = 1;
          %   opacity(mask&(image_pano > 0)) = 0.5;
             
            % Overlay the warpedImage onto the panorama.
             image_pano = step(blender, image_pano, warpedImage, mask);
             mask_pano = step(blender, mask_pano, i*double(mask), mask);
            
         end
         
                
         % TO-DO this is temporal measure, since there is horizontal
         % lines in some framelets
         image_pano = medfilt2(image_pano, [3, 1]);
     
         raw_pano = image_pano;
         
         % here we produce georeferenced pano
         % in this pano lattitude correspond to Y and longitude to X
         tform = fitgeotrans([x_pano(:) y_pano(:)], [lon_pano(:) lat_pano(:)],'projective');
                  
         mInput = size(image_pano,1);
         nInput = size(image_pano,2);
         
         inputCorners = 0.5 ...
             + [0        0;
             0        mInput;
             nInput   mInput;
             nInput   0;
             0        0];
         
         outputCornersSpatial = transformPointsForward(tform, inputCorners);
         
         outputCornersLon = outputCornersSpatial(:,1);
         outputCornersLat = outputCornersSpatial(:,2);
                    
         pixelSize = [hypot( ...
             outputCornersLon(2) - outputCornersLon(1), ...
             outputCornersLat(2) - outputCornersLat(1)) / mInput, ...
             hypot( ...
             outputCornersLon(4) - outputCornersLon(5), ...
             outputCornersLat(4) - outputCornersLat(5)) / nInput];
         
         outputPixelSize  = max(pixelSize); 
         
         lonWorldLimits = outputPixelSize ...
             * [floor(min(outputCornersLon) / outputPixelSize), ...
             ceil(max(outputCornersLon) / outputPixelSize)];
         
         latWorldLimits = outputPixelSize ...
             * [floor(min(outputCornersLat) / outputPixelSize), ...
             ceil(max(outputCornersLat) / outputPixelSize)];
         
         mOutput = round(diff(latWorldLimits) / outputPixelSize);
         nOutput = round(diff(lonWorldLimits) / outputPixelSize);
         %residuals = transformPointsForward(tform, [x_pano(:) y_pano(:)]) - [lon_pano(:) lat_pano(:)];
         
        R = imref2d([mOutput nOutput],lonWorldLimits,latWorldLimits);
        
        
        if latWorldLimits(1) < latWorldLimits(2) 
            if lonWorldLimits(1) < lonWorldLimits(2)
                image_pano = flipud(imwarp(image_pano, tform, 'OutputView', R));
            else
                image_pano = fliprl(flipud(imwarp(image_pano, tform, 'OutputView', R)));
            end
        else
            if lonWorldLimits(1) < lonWorldLimits(2)
                image_pano = (imwarp(image_pano, tform, 'OutputView', R));
            else
                image_pano = fliprl((imwarp(image_pano, tform, 'OutputView', R)));
            end
        end
        
        
        Rgeo = georasterref('RasterSize',R.ImageSize, ...
        'LatitudeLimits',latWorldLimits,'LongitudeLimits',lonWorldLimits, 'ColumnsStartFrom','north');
    
         Rmap = maprasterref('RasterSize',R.ImageSize, ...
        'YWorldLimits',R.YWorldLimits,'XWorldLimits',R.XWorldLimits, 'ColumnsStartFrom','north');
    
    
    %% 
%         figure;
        
     %    [lon lat] = [row col 1] * R
       % R = pinv([y_pano(:) x_pano(:) ones(size(x_pano(:)))])*[lon_pano(:) lat_pano(:)]; 
       % Rmap = georasterref(R', size(image_pano))
               
        
%        figure;
        %axesm('MapProjection','sinusoid') 
    %    geoshow(image_pano, Rgeo);
%        xlabel('lon');
%        ylabel('lat');
    
    
    
  %      expID_pano = uint8(expID_pano);
         mask_pano = mask_pano > 0;   
      end
   end
      
%       function [image_pano, Rgeo, Rmap, raw_pano, mask_pano] = getImage(obj, nSubExp)
%                 
%         
%         blender = vision.AlphaBlender('Operation', 'Binary mask', ...
%         'MaskSource', 'Input port'); 
% 
%          % find panorama size 
%          x_max = max(obj.dx+obj.refFrame_xywh{nSubExp}(:,3));
%          x_min = min(obj.dx+1);
% 
%          y_max = max(obj.dy+obj.refFrame_xywh{nSubExp}(:,4));
%          y_min = min(obj.dy+1);
%          
%          width  = ceil(x_max - x_min + 1);
%          height = ceil(y_max - y_min + 1);
%          
%          image_pano = zeros(height, width);
%          mask_pano = zeros(height, width);
%          
%          xLimits = [x_min x_max];
%          yLimits = [y_min y_max];
%          
%          panoramaView = imref2d([height width], xLimits, yLimits);
%         
%          % find optimal intensity limits
%          lim = stretchlim(obj.framelet{nSubExp}(:));
%                   
%          % create the panorama by adressing one framelet at the time.
%          x_pano =[];
%          y_pano = [];
%          lat_pano = [];
%          lon_pano = [];
%          for i = 1:length(obj.time)
%             
%              % define transformation
%              tform = affine2d([1 0 0; 0 1 0; obj.dx(i) obj.dy(i) 1]);
%              
%              % get coordinates of framelet border for georeferencing
%              w = obj.refFrame_xywh{nSubExp}(:,3);
%              h = obj.refFrame_xywh{nSubExp}(:,4);
%              x11 = obj.refFrame_xywh{nSubExp}(:,1);
%              y11 = obj.refFrame_xywh{nSubExp}(:,2);
%              x_framelet = [x11 x11   x11+w x11+w];
%              y_framelet = [y11 y11+h y11   y11+h];
%              
%              [lat_framelet, lon_framelet] = getPixLatLon(x_framelet, y_framelet, obj.time(i));
%              
%              % compute coordinates of the framelet in pano
%              [x_framelet_pano, y_framelet_pano] = transformPointsForward(tform, x_framelet, y_framelet);
%              x_pano = [x_pano;x_framelet_pano];
%              y_pano = [y_pano;y_framelet_pano];
%              lat_pano = [lat_pano;lat_framelet];
%              lon_pano = [lon_pano;lon_framelet];
%              
%              framelet = imadjust(double(obj.framelet{nSubExp}(:,:,i)),lim);
%               
%              warpedImage = imwarp(framelet, tform, 'OutputView', panoramaView);
%              
%             % Generate a binary mask.
%              mask = imwarp(true(size(framelet,1),size(framelet,2)), tform, 'OutputView', panoramaView);
%           %  opacity = zeros(size(image_pano));
%           %   opacity(mask) = 1;
%           %   opacity(mask&(image_pano > 0)) = 0.5;
%              
%             % Overlay the warpedImage onto the panorama.
%              image_pano = step(blender, image_pano, warpedImage, mask);
%              mask_pano = step(blender, mask_pano, i*double(mask), mask);
%             
%          end
%          
%                 
%          % TO-DO this is temporal measure, since there is horizontal
%          % lines in some framelets
%          image_pano = medfilt2(image_pano, [3, 1]);
%      
%          raw_pano = image_pano;
%          
%          % here we produce georeferenced pano
%          % in this pano lattitude correspond to Y and longitude to X
%          tform = fitgeotrans([x_pano(:) y_pano(:)], [lon_pano(:) lat_pano(:)],'projective');
%                   
%          mInput = size(image_pano,1);
%          nInput = size(image_pano,2);
%          
%          inputCorners = 0.5 ...
%              + [0        0;
%              0        mInput;
%              nInput   mInput;
%              nInput   0;
%              0        0];
%          
%          outputCornersSpatial = transformPointsForward(tform, inputCorners);
%          
%          outputCornersLon = outputCornersSpatial(:,1);
%          outputCornersLat = outputCornersSpatial(:,2);
%                     
%          pixelSize = [hypot( ...
%              outputCornersLon(2) - outputCornersLon(1), ...
%              outputCornersLat(2) - outputCornersLat(1)) / mInput, ...
%              hypot( ...
%              outputCornersLon(4) - outputCornersLon(5), ...
%              outputCornersLat(4) - outputCornersLat(5)) / nInput];
%          
%          outputPixelSize  = max(pixelSize); 
%          
%          lonWorldLimits = outputPixelSize ...
%              * [floor(min(outputCornersLon) / outputPixelSize), ...
%              ceil(max(outputCornersLon) / outputPixelSize)];
%          
%          latWorldLimits = outputPixelSize ...
%              * [floor(min(outputCornersLat) / outputPixelSize), ...
%              ceil(max(outputCornersLat) / outputPixelSize)];
%          
%          mOutput = round(diff(latWorldLimits) / outputPixelSize);
%          nOutput = round(diff(lonWorldLimits) / outputPixelSize);
%          %residuals = transformPointsForward(tform, [x_pano(:) y_pano(:)]) - [lon_pano(:) lat_pano(:)];
%          
%         R = imref2d([mOutput nOutput],lonWorldLimits,latWorldLimits);
%         
%         
%         if latWorldLimits(1) < latWorldLimits(2) 
%             if lonWorldLimits(1) < lonWorldLimits(2)
%                 image_pano = flipud(imwarp(image_pano, tform, 'OutputView', R));
%             else
%                 image_pano = fliprl(flipud(imwarp(image_pano, tform, 'OutputView', R)));
%             end
%         else
%             if lonWorldLimits(1) < lonWorldLimits(2)
%                 image_pano = (imwarp(image_pano, tform, 'OutputView', R));
%             else
%                 image_pano = fliprl((imwarp(image_pano, tform, 'OutputView', R)));
%             end
%         end
%         
%         
%         Rgeo = georasterref('RasterSize',R.ImageSize, ...
%         'LatitudeLimits',latWorldLimits,'LongitudeLimits',lonWorldLimits, 'ColumnsStartFrom','north');
%     
%          Rmap = maprasterref('RasterSize',R.ImageSize, ...
%         'YWorldLimits',R.YWorldLimits,'XWorldLimits',R.XWorldLimits, 'ColumnsStartFrom','north');
%     
%     
%     %% 
% %         figure;
%         
%      %    [lon lat] = [row col 1] * R
%        % R = pinv([y_pano(:) x_pano(:) ones(size(x_pano(:)))])*[lon_pano(:) lat_pano(:)]; 
%        % Rmap = georasterref(R', size(image_pano))
%                
%         
% %        figure;
%         %axesm('MapProjection','sinusoid') 
%     %    geoshow(image_pano, Rgeo);
% %        xlabel('lon');
% %        ylabel('lat');
%     
%     
%     
%   %      expID_pano = uint8(expID_pano);
%          mask_pano = mask_pano > 0;   
%       end
%    end
%    
end