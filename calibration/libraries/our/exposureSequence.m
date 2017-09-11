classdef exposureSequence
   properties
       
       image_size = [2048 2048];
       
       %% camera parameters
       % lens distorition
       corr2distA
       dist2corrA
       % intrinsic
       f 
       x0
       y0
       pixSize
       
       %% image data
       % all subExp_sensors are saved in chronological order
       subExp_sensor      % {nSubExp}(:,:,nExp) 
       exp_time           % (nExp)
       exp_length         % (nExp)
       subExp_sensor_pos  % {nSubExp} position of subexposure on sensor
       
       
       dx  % position of subExp_sensor in image
       dy
   end
   methods
       
      function obj = exposureSequence(path, fname_list, islevel0)
       
          % 'float=>float' for level 1
          % 'uint16=>uint16' for level 0
          
          for nfile = 1:length(fname_list)
              
              fname = [path '/' fname_list{nfile}];
              
              [~, time_str, nExp, nSubExp] = cassis_parse_filename(fname_list{nfile});  
              nExp = nExp + 1;          % nExp and nSubExp should start from 1
              nSubExp = nSubExp + 1;
              obj.exp_time(nExp) = cassis_time2num(time_str);
              
              if islevel0
                 [obj.subExp_sensor{nSubExp}(:,:,nExp), obj.subExp_sensor_pos{nSubExp}, obj.exp_length] = cassis_read_subexp(fname, 'uint16=>uint16');  
              else
                 [obj.subExp_sensor{nSubExp}(:,:,nExp), obj.subExp_sensor_pos{nSubExp}, obj.exp_length] = cassis_read_subexp(fname, 'float=>float');  
              end
                                          
          end
          
          % sort all frames by time 
          [obj.exp_time, index] = sort(obj.exp_time);
          
          nbSubExp = length(obj.subExp_sensor);
          for nSubExp = 1:nbSubExp
            obj.subExp_sensor{nSubExp} = obj.subExp_sensor{nSubExp}(:,:,index); 
          end
          
      end
      
      function nbSubExp = getSubExpNb(obj) 
          
        nbSubExp = length(obj.subExp_sensor);
        
      end
      
      function nbExp = getExpNb(obj) 
          
        nbExp = length(obj.exp_time);
        
      end
      
      function [exp_mapProj, mask_mapProj, Rmap] = getMapProjExp(obj, nExp, subExp_vec, corrLensDist_on, adjustSubExp_on)
         
          
          [exp, mask] = getExp(obj, nExp, subExp_vec, corrLensDist_on, true, adjustSubExp_on); % virtual image
          
          [x0_sen, y0_sen, w, h] = getExpSensorBound(obj);
          xe_sen = x0_sen + w;
          ye_sen = y0_sen + h;
          xy_sen = [x0_sen, y0_sen;
                    xe_sen, y0_sen;
                    xe_sen, ye_sen;
                    x0_sen, ye_sen];% start from top-left, proceed in clockwise direction
          
          [xy_vir(:,1), xy_vir(:,2)] = cassis_sensor2virtual(xy_sen(:,1), xy_sen(:,2), obj.image_size(1));
                        
          [latLon(:,1), latLon(:,2)] = getExpMapBound(obj, nExp);
          
          % get pixel size
          pixelSize = max([hypot( ...
               latLon(1,2) - latLon(2,2), ...
               latLon(1,1) - latLon(2,1)) / w, ...
               hypot( ...
               latLon(1,2) - latLon(4,2), ...
               latLon(1,1) - latLon(4,1)) / h]);
          
          % get wold limits
          lonLimits = pixelSize ...
            * [floor(min(latLon(:,2)) / pixelSize), ...
               ceil(max(latLon(:,2)) / pixelSize)];
           
          latLimits = pixelSize ...
               * [floor(min(latLon(:,1)) / pixelSize), ...
               ceil(max(latLon(:,1)) / pixelSize)];
          
          H = round(diff(latLimits) / pixelSize);
          W = round(diff(lonLimits) / pixelSize);
          ref = imref2d([H W], lonLimits, latLimits);
           
          tform = fitgeotrans([xy_vir(:,1) xy_vir(:,2)], [latLon(:,2) latLon(:,1)],'projective'); % longitude projects to x 
          exp_mapProj = imwarp(exp, tform, 'OutputView', ref);
          mask_mapProj = imwarp(mask, tform, 'OutputView', ref);

          % canonically:
          % 1. lattitude decrease from top to bottom 
          % 2. longitude increase from left to right
          if latLimits(1) < latLimits(2)
               exp_mapProj = flipud(exp_mapProj);
               mask_mapProj = flipud(mask_mapProj);
          end
          if lonLimits(1) > lonLimits(2)
               exp_mapProj =  fliprl(exp_mapProj);
               mask_mapProj =  fliprl(mask_mapProj);
          end
          
          Rmap = maprasterref('RasterSize', ref.ImageSize, ...
               'YWorldLimits', ref.YWorldLimits,'XWorldLimits', ref.XWorldLimits, 'ColumnsStartFrom','north', 'RowsStartFrom','west');
          
%           figure; 
%           exp_mapProj = im2uint16(exp_mapProj);
%           mapshow(exp_mapProj, Rmap);
%           xlabel('lon');
%           ylabel('lat');
      end
      
      function [exp, mask] = getExp(obj, nExp, subExp_vec, corrLensDist_on, virtualImage_on, adjustSubExp_on)
          
          mask = false(obj.image_size); 
          exp = zeros(obj.image_size);
              
          nbSubExp = length(subExp_vec);
          
          for subExp_idx = 1:nbSubExp
              
              nSubExp = subExp_vec(subExp_idx);              
              
              [x0_sensor, y0_sensor, w, h] = obj.getSubExpSensorBound(nSubExp);
                           
              [subExp, subExp_mask] = getSubExp(obj, nSubExp, nExp, corrLensDist_on, adjustSubExp_on);

              exp(y0_sensor:y0_sensor + h - 1, x0_sensor:x0_sensor + w - 1) = subExp; 
              mask(y0_sensor:y0_sensor + h - 1, x0_sensor:x0_sensor + w - 1) = subExp_mask; 
          
          end 

          if virtualImage_on
                
              exp = (flipud(exp));
              mask = (flipud(mask));
                       
          end
          
      end
          
          % get coordinates of subExp_sensor border for georeferencing
%          w = 2048;
%          h = 2048;
%          x11 = 1;
%          y11 = 1;
%          x_subExp_sensor = [x11 x11   x11+w x11+w];
%          y_subExp_sensor = [y11 y11+h y11   y11+h];
%          [lat, lon] = getPixLatLon(x_subExp_sensor, y_subExp_sensor, obj.time(nExp));
          
%           tform = fitgeotrans([x_subExp_sensor(:) y_subExp_sensor(:)], [lon(:) lat(:)],'projective');
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
      
      function err = estimateDistortion(obj, subExp_vec, corrLensDist_on)
         
         diff(1,:) = [0, 0];
         
         nbExp = obj.getExpNb();
         
         for nExp = 1:4
             
             virtualImage_on = true;
             adjustSubExp_on = true;
             [exp1, ~] = obj.getExp(nExp, subExp_vec, corrLensDist_on, virtualImage_on, adjustSubExp_on);
             [exp2, mask] = obj.getExp(nExp+1, subExp_vec, corrLensDist_on, virtualImage_on, adjustSubExp_on);
             
             % get features
             th = 1000;
             pts1 = detectSURFFeatures(exp1,'MetricThreshold',th);
             pts2 = detectSURFFeatures(exp2,'MetricThreshold',th);
             [features1, validPts1]  = extractFeatures(exp1,  pts1);
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
             matchPts1 = validPts1(indexPairs(:,1));
             matchPts2 = validPts2(indexPairs(:,2));
             
             com = nchoosek(1:length(matchPts1),uint16(2));
             len1 = sqrt(sum((matchPts1(com(:,1)).Location - matchPts1(com(:,2)).Location).^2,2));
             len2 = sqrt(sum((matchPts2(com(:,1)).Location - matchPts2(com(:,2)).Location).^2,2));
             
             valid = abs(len1 - len2) < 15;
             len_diff(nExp) = mean(abs(len1(valid) - len2(valid)));             
             
         end
%          
%          % fit shifts (assume that they changes linearly from exposure to
%          % exposure)
%          b = robustfit([1:length(obj.exp_time)-1], diff(2:end,1));
%          diff(2:end,1) = b(1) + b(2)*[1:length(obj.exp_time)-1];
% 
%          b = robustfit([1:length(obj.exp_time)-1], diff(2:end,2));
%          diff(2:end,2) = b(1) + b(2)*[1:length(obj.exp_time)-1];
%          
%          obj.dx = cumsum(diff(:,1));
%          obj.dy = cumsum(diff(:,2));
%          
           err = mean(len_diff);
      end  
               
      function obj = registerExp(obj, subExp_vec, corrLensDist_on)
         
         diff(1,:) = [0, 0];
         
         nbExp = obj.getExpNb();
         
         for nExp = 1:nbExp-1
             
             virtualImage_on = true;
             adjustSubExp_on = true;
             [exp1, ~] = obj.getExp(nExp, subExp_vec, corrLensDist_on, virtualImage_on, adjustSubExp_on);
             [exp2, mask] = obj.getExp(nExp+1, subExp_vec, corrLensDist_on, virtualImage_on, adjustSubExp_on);
             
             % get features
             th = 1000;
             pts1 = detectSURFFeatures(exp1,'MetricThreshold',th);
             pts2 = detectSURFFeatures(exp2,'MetricThreshold',th);
             [features1, validPts1]  = extractFeatures(exp1,  pts1);
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
            % [tformTotal,~,~,status] = estimateGeometricTransform(validPts2(indexPairs(:,2)),...
            %     validPts1(indexPairs(:,1)),'similarity');
            
             diff(nExp+1,:) = median(validPts2(indexPairs(:,2)).Location - validPts1(indexPairs(:,1)).Location);
           %  if status == 0
           %      diff(nExp+1,:) = [tformTotal.T(3,1) tformTotal.T(3,2)];
           %  else
           %      diff(nExp+1,:) = [nan nan];
           %  end
         end
         
         % fit shifts (assume that they changes linearly from exposure to
         % exposure)
         b = robustfit([1:length(obj.exp_time)-1], diff(2:end,1));
         diff(2:end,1) = b(1) + b(2)*[1:length(obj.exp_time)-1];

         b = robustfit([1:length(obj.exp_time)-1], diff(2:end,2));
         diff(2:end,2) = b(1) + b(2)*[1:length(obj.exp_time)-1];
         
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
%          width  = ceil(x  [lat_subExp_sensor, lon_subExp_sensor] = getPixLatLon(x_subExp_sensor, y_subExp_sensor, obj.time(i));_max - x_min + 1);
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
%          lim = stretchlim(obj.subExp_sensor{nSubExp}(:));
%                   
%          % Create the panorama.
%          for i = 1:length(obj.time)
%             
%             tform = affine2d([1 0 0; 0 1 0; obj.dx(i) obj.dy(i) 1]);
%             
%             subExp_sensor = imadjust(double(obj.subExp_sensor{nSubExp}(:,:,i)),lim);
%             warpedImage = imwarp(subExp_sensor, tform, 'OutputView', panoramaView);
% 
%             % Generate a binary mask.
%             mask = imwarp(true(size(subExp_sensor,1),size(subExp_sensor,2)), tform, 'OutputView', panoramaView);
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
      function obj = setIntrinsics(obj, f, x0, y0, pixSize)
            
          obj.f = f; 
          obj.x0 = x0;
          obj.y0 = y0;
          obj.pixSize = pixSize;
          
      end
      
     
      function obj = setLensDistortion(obj, dist2corrA)
            
          % distorted-2-undistorted
          obj.dist2corrA = dist2corrA; 
          
          % undistorted-2-distorted
          [obj.corr2distA, maxErr] = inverse_rational_model(dist2corrA, obj.image_size);
          if( maxErr > 3e-2)
            warning('Error of the inverse rational model is too high!');
          end
          
      end
      
      %function [x_vir, y_vir] = getSubExpVirtualBound(obj, nSubExp)
          
          % Extent of the sub-exposure on virtual plane
          % Clock-wise starting from Left-
       %  [x_sensor, y_sensor, w, h] = deal(obj.subExp_sensor_pos{nSubExp}(1), obj.subExp_sensor_pos{nSubExp}(2),...
        %             obj.subExp_sensor_pos{nSubExp}(3), obj.subExp_sensor_pos{nSubExp}(4));
      
      %end
            
      function [x0_sensor, y0_sensor, w, h] = getSubExpSensorBound(obj, nSubExp)
          
         [x0_sensor, y0_sensor, w, h] = deal(obj.subExp_sensor_pos{nSubExp}(1), obj.subExp_sensor_pos{nSubExp}(2),...
                     obj.subExp_sensor_pos{nSubExp}(3), obj.subExp_sensor_pos{nSubExp}(4));
      
      end
      
      function [x0_sensor, y0_sensor, w, h] = getExpSensorBound(obj)
                   
         [x0_sensor, y0_sensor, w, h] = deal(1, 1, obj.image_size(2), obj.image_size(1));
      
      end
      
      function [lat, lon] = getExpMapBound(obj, nExp)
          
          [x0_sen, y0_sen, w, h] = getExpSensorBound(obj);
          xe_sen = x0_sen + w;
          ye_sen = y0_sen + h;
          xy_sen = [x0_sen, y0_sen;
                    xe_sen, y0_sen;
                    xe_sen, ye_sen;
                    x0_sen, ye_sen]; % start from top-left, proceed in clockwise direction
                    
          % sensor to virtual image 
          [xy_vir(:,1), xy_vir(:,2)] = cassis_sensor2virtual(xy_sen(:,1), xy_sen(:,2), obj.image_size(1));
                    
          % virtual image to lat lon 
          timenum = obj.getExpTime(nExp);
          [f, pixSize, x0, y0] = obj.getIntrinsics();
          [latLon(:,1), latLon(:,2)] = xy_virtualPlane_2_latLon(xy_vir(:,1), xy_vir(:,2), timenum, pixSize, f, x0, y0);
          [lat, lon] = deal(latLon(:,1), latLon(:,2));
      
      end
      
      function [lat, lon] = getSubExpMapBound(obj, nExp, nSubExp)
          
          [x0_sen, y0_sen, w, h] = obj.getSubExpSensorBound(nSubExp);
          xe_sen = x0_sen + w;
          ye_sen = y0_sen + h;
          
          % left-top, right-top, right-bottom, left-bottom
          xy_sen = [x0_sen y0_sen; xe_sen y0_sen; xe_sen ye_sen; x0_sen ye_sen];  
          
          % sensor to virtual image 
          [xy_vir(:,1), xy_vir(:,2)] = cassis_sensor2virtual(xy_sen(:,1), xy_sen(:,2), obj.image_size(1));
                    
          % virtual image to lat lon 
          timenum = obj.getExpTime(nExp);
          [f, pixSize, x0, y0] = obj.getIntrinsics();
          [latLon(:,1), latLon(:,2)] = xy_virtualPlane_2_latLon(xy_vir(:,1), xy_vir(:,2), timenum, pixSize, f, x0, y0);
          [lat, lon] =deal(latLon(:,1), latLon(:,2));
      
      end
      
      function time = getExpTime(obj, nExp)
          
         time = obj.exp_time(nExp);
         
      end
      
      function [f, pixSize, x0, y0] = getIntrinsics(obj)
          
          f = obj.f; 
          x0 = obj.x0;
          y0 = obj.y0;
          pixSize = obj.pixSize;
         
      end
      
      function [subExp, mask] = getSubExp(obj, nSubExp, nExp, corrLensDist_on, adjustSubExp_on)
         
          subExp = obj.subExp_sensor{nSubExp}(:,:,nExp);
          mask = true(size(subExp));
                              
          % correct distortion
          if( corrLensDist_on ) 
                
              [x_subExp, y_subExp] = meshgrid(1:size(subExp,2), 1:size(subExp,1));
              
              % subexposure-2-sensor coordinates
              [x0_sensor, y0_sensor, ~, ~] = getSubExpSensorBound(obj, nSubExp);
              [x_sensor, y_sensor] = cassis_subexp2sensor(x_subExp, y_subExp, x0_sensor, y0_sensor);
              
              % sensor-2-frontal focal plane coordinates
              [x_front, y_front] = cassis_sensor2virtual(x_sensor, y_sensor, obj.image_size(1));
             % x_front = x_sensor;
             % y_front  = y_sensor;
              
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
              
              [i_sensor, j_sensor] = cassis_virtual2sensor(i_front, j_front, obj.image_size(1));  
             %  i_sensor = i_front;
             %  j_sensor = j_front;
             
              % sensor-2-subexposure
              [i_subExp, j_subExp] = cassis_sensor2subexp(i_sensor, j_sensor,  x0_sensor, y0_sensor);
              
              % interpolate
              subExp = interp2(x_subExp, y_subExp, subExp, i_subExp, j_subExp);
           
          end
        
          mask = true(size(subExp));
          mask(:,1:5) = false;
          mask(:,end-4:end) = false;
          mask(1:5,:) = false;
          mask(end-4:end,:) = false;
          
          if adjustSubExp_on
              
            lim = getSubExpStretchLim(obj, nSubExp);
            subExp = imadjust(subExp,lim);
           % subExp(~mask) = 0;
            
          end
                  
      end
      
%       function y = getSubExpShift(obj)
%           
%           nbSubExp = length(self.subExp_sensor);  
%           x = zeros(nbSubExp);
%           y = zeros(nbSubExp);
%           for nSubExp = 1:nbSubExp
%             [x(nSubExp), y(nSubExp), ~, ~] = getSubExpBound(obj, nSubExp);
%           end
%           y = y - min(y);
%           
%       end

      function color = getColor(obj, subExp_vec, corrLensDist_on)
                 
          if length(subExp_vec) ~= 3 
              warning('number of channels should be 3');
          end
                 
          [Iref, mask_pano, ref] = obj.getMapProjImage( subExp_vec(1), corrLensDist_on);
          [I{1}, mask_pano] = obj.getMapProjImage(subExp_vec(2), corrLensDist_on, ref);
          [I{2}, mask_pano] = obj.getMapProjImage(subExp_vec(3), corrLensDist_on, ref);

          th = 1000;
          pts_ref = detectSURFFeatures(Iref,'MetricThreshold',th);
          [feat_ref,  validPts_ref]  = extractFeatures(Iref,  pts_ref);

          for i = 1:2
              
             th = 1000;
             pts = detectSURFFeatures(I{i},'MetricThreshold',th);
             [feat,  validPts]  = extractFeatures(I{i},  pts);
           
             indexPairs = matchFeatures(feat_ref, feat);
             diff = median(validPts_ref(indexPairs(:,1)).Location - validPts(indexPairs(:,2)).Location);
            
             tform = affine2d([1 0 0; 0 1 0; diff(1) diff(2) 1]);
             I{i} = imwarp(I{i}, tform, 'OutputView', imref2d(size(Iref)));
          end   
          
          color = cat(3,Iref,I{1},I{2});
           %  tform = affine2d([1 0 0; 0 1 0; x0_front(nSubExp) + obj.dx(nExp) y0_front(nSubExp) + obj.dy(nExp) 1]);
             
             % compute coordinates of the subExp_sensor in pano
             %[x_subExp_sensor_pano, y_subExp_sensor_pano] = transformPointsForward(tform, x_subExp_sensor, y_subExp_sensor);
             %x_pano = [x_pano;x_subExp_sensor_pano];
     %        %y_pano = [y_pano;y_subExp_sensor_pano];
      %       [exp, mask] = obj.getExp(nExp, [nSubExp], corrLensDist_on,  true, true);
             
             %subExp = imadjust(double(subExp),lim);
%             warpedImage = imwarp(double(exp), tform, 'OutputView', imref2d(size();
        
              

%            
%           for i = 2:3
%             [image, ~] = getImage(obj, subExps(i), corrLensDist_on);   
%              
%               
%           end
%           
%           % match features
%           [tformTotal,~,~,status] = estimateGeometricTransform(validPts2(indexPairs(:,2)),...
%                  validPts1(indexPairs(:,1)),'similarity');
%             
%              diff(nExp+1,:) = [tformTotal.T(3,1) tformTotal.T(3,2)];
      end
      
      function lim = getSubExpStretchLim(obj, nSubExp)
          
            lim = stretchlim(reshape(obj.subExp_sensor{nSubExp}(2:end-2,:,:),[],1));
      
      end
      
      
      function [pano, pano_mask, pano_ref] = getMapProjImage(obj, nSubExp, corrLensDist_on, pano_ref)
      
          %% find Lat /  Lon limits and scale (deg in pixel)
          lat = [];
          lon = [];
          nbExp = obj.getExpNb();
          
          if nargin < 4 
              for nExp = 1:nbExp
                  [~, ~, w, h] = obj.getSubExpSensorBound(nSubExp);
                  [lat_tmp, lon_tmp] = obj.getSubExpMapBound(nExp, nSubExp);
                  lat = [lat; lat_tmp];
                  lon = [lon; lon_tmp];
                  deg_per_pix(nExp) = max((hypot(lat_tmp(1)-lat_tmp(2), lon_tmp(1) - lon_tmp(2)) / w),...
                               (hypot(lat_tmp(1)-lat_tmp(4), lon_tmp(1) - lon_tmp(4)) / h));  
              end

              max_deg_per_pix = max(deg_per_pix);
              max_lat = max(lat);
              min_lat = min(lat);
              max_lon = max(lon);
              min_lon = min(lon);
    
              lonWorldLimits = max_deg_per_pix ...
             * [floor(min_lon / max_deg_per_pix), ...
             ceil(max_lon / max_deg_per_pix)];
         
            latWorldLimits = max_deg_per_pix...
             * [floor(min_lat / max_deg_per_pix), ...
             ceil(max_lat / max_deg_per_pix)];
           
              pano_width  = round(diff([lonWorldLimits]) / max_deg_per_pix);
              pano_height = round(diff([latWorldLimits]) / max_deg_per_pix);
              pano_ref = imref2d([pano_height pano_width], lonWorldLimits, latWorldLimits);
          else
              pano_width = pano_ref.ImageSize(2); 
              pano_height = pano_ref.ImageSize(1);
          end
          
          %% reproject 
          blender = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port'); 
          pano = zeros(pano_height, pano_width);
          pano_mask = zeros(pano_height, pano_width);
          
          for nExp = 1:nbExp
              
              [x0_sen, y0_sen, w, h] = obj.getSubExpSensorBound(nSubExp);
              xe_sen = x0_sen + w;
              ye_sen = y0_sen + h;
              [lat, lon] = obj.getSubExpMapBound(nExp, nSubExp);
              lonLat = [lon lat];
              xy_sen = [x0_sen y0_sen; xe_sen y0_sen; xe_sen ye_sen; x0_sen ye_sen];  
              tform = fitgeotrans(xy_sen, lonLat, 'projective');
              
              [subExp, subExp_mask] = obj.getSubExp(nSubExp, nExp, corrLensDist_on, true);
              inputRef = imref2d(size(subExp), [x0_sen xe_sen], [y0_sen ye_sen]);
              warped_subExp = imwarp(double(subExp), inputRef, tform, 'OutputView', pano_ref);
              warped_subExp_mask = imwarp(subExp_mask,inputRef, tform, 'nearest', 'OutputView', pano_ref);
             % warped_subExp(~warped_subExp_mask) = 0;  
              
              pano = step(blender, pano, warped_subExp, warped_subExp_mask>0);
              pano_mask = step(blender, pano_mask, double(warped_subExp_mask), warped_subExp_mask>0);
             
          end
          
      end
      
      function [image_pano, mask_pano] = getImage(obj, nSubExp, corrLensDist_on)
                
            
         blender = vision.AlphaBlender('Operation', 'Binary mask', ...
        'MaskSource', 'Input port'); 
        
%          nbSubExp = obj.getSubExpNb();
%          
%          for nSubExp_ = 1:nbSubExp
%             [x0_sensor, y0_sensor, w, h] =  getSubExpSensorBound(obj, nSubExp_);
%             xe_sensor = x0_sensor + w;
%             ye_sensor = y0_sensor + h;
%             % since we flip image, y end and start points are swapt
%             [xe_front(nSubExp_), y0_front(nSubExp_)] = cassis_sensor2front(xe_sensor, ye_sensor, obj.image_size(1));
%             [x0_front(nSubExp_), ye_front(nSubExp_)] = cassis_sensor2front(x0_sensor, y0_sensor, obj.image_size(1));
%          end
                  
%         x_front_min = min(x0_front);
%         x_front_max = max(xe_front);
%         y_front_min = min(y0_front);
%         y_front_max = max(ye_front);
                  
         x_max = max(-obj.dx+obj.image_size(2));
         x_min = min(-obj.dx+1);

         y_max = max(-obj.dy+obj.image_size(1));
         y_min = min(-obj.dy+1);
         
         width  = ceil(x_max - x_min + 1);
         height = ceil(y_max - y_min + 1);
         
         image_pano = zeros(height, width);
         mask_pano = zeros(height, width);
         
         xLimits = [x_min x_max];
         yLimits = [y_min y_max];
         
         panoramaView = imref2d([height width], xLimits, yLimits);
        
         % find optimal intensity limits
 %        lim = stretchlim(obj.subExp_sensor{nSubExp}(:));
                  
         % create the panorama by adressing one subExp_sensor at the time.
%          x_pano =[];
%          y_pano = [];
%          lat_pano = [];
%          lon_pano = [];
%          
         nbExp = length(obj.exp_time);
         
         for nExp = 1:nbExp
            
             tform = affine2d([1 0 0; 0 1 0; -obj.dx(nExp) -obj.dy(nExp) 1]);
           %  tform = affine2d([1 0 0; 0 1 0; x0_front(nSubExp) + obj.dx(nExp) y0_front(nSubExp) + obj.dy(nExp) 1]);
             
             % compute coordinates of the subExp_sensor in pano
             %[x_subExp_sensor_pano, y_subExp_sensor_pano] = transformPointsForward(tform, x_subExp_sensor, y_subExp_sensor);
             %x_pano = [x_pano;x_subExp_sensor_pano];
             %y_pano = [y_pano;y_subExp_sensor_pano];
             [exp, mask] = obj.getExp(nExp, [nSubExp], corrLensDist_on,  true, true);
             
             %subExp = imadjust(double(subExp),lim);
             warpedImage = imwarp(double(exp), tform, 'OutputView', panoramaView);
             
            % Generate a binary mask.
             mask = imwarp(mask, tform, 'OutputView', panoramaView);
          %  opacity = zeros(size(image_pano));
          %   opacity(mask) = 1;
          %   opacity(mask&(image_pano > 0)) = 0.5;
             
            % Overlay the warpedImage onto the panorama.
             image_pano = step(blender, (image_pano), warpedImage, mask);
             mask_pano = step(blender, (mask_pano), double(mask), mask);
            
         end
         
                
         % TO-DO this is temporal measure, since there is horizontal
         % lines in some subExp_sensors
         image_pano = medfilt2(image_pano, [3, 1]);
     
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
%          lim = stretchlim(obj.subExp_sensor{nSubExp}(:));
%                   
%          % create the panorama by adressing one subExp_sensor at the time.
%          x_pano =[];
%          y_pano = [];
%          lat_pano = [];
%          lon_pano = [];
%          for i = 1:length(obj.time)
%             
%              % define transformation
%              tform = affine2d([1 0 0; 0 1 0; obj.dx(i) obj.dy(i) 1]);
%              
%              % get coordinates of subExp_sensor border for georeferencing
%              w = obj.refFrame_xywh{nSubExp}(:,3);
%              h = obj.refFrame_xywh{nSubExp}(:,4);
%              x11 = obj.refFrame_xywh{nSubExp}(:,1);
%              y11 = obj.refFrame_xywh{nSubExp}(:,2);
%              x_subExp_sensor = [x11 x11   x11+w x11+w];
%              y_subExp_sensor = [y11 y11+h y11   y11+h];
%              
%              [lat_subExp_sensor, lon_subExp_sensor] = getPixLatLon(x_subExp_sensor, y_subExp_sensor, obj.time(i));
%              
%              % compute coordinates of the subExp_sensor in pano
%              [x_subExp_sensor_pano, y_subExp_sensor_pano] = transformPointsForward(tform, x_subExp_sensor, y_subExp_sensor);
%              x_pano = [x_pano;x_subExp_sensor_pano];
%              y_pano = [y_pano;y_subExp_sensor_pano];
%              lat_pano = [lat_pano;lat_subExp_sensor];
%              lon_pano = [lon_pano;lon_subExp_sensor];
%              
%              subExp_sensor = imadjust(double(obj.subExp_sensor{nSubExp}(:,:,i)),lim);
%               
%              warpedImage = imwarp(subExp_sensor, tform, 'OutputView', panoramaView);
%              
%             % Generate a binary mask.
%              mask = imwarp(true(size(subExp_sensor,1),size(subExp_sensor,2)), tform, 'OutputView', panoramaView);
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
%          % lines in some subExp_sensors
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