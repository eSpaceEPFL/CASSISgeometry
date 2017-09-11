function [x_focalplane, y_focalplane] = cassis_detector2focalplane(x_detector, y_detector, width, height, pixel_pitch)
    
    % convert detector coordinates to focal plane coordinates
    x_focalplane = (x_detector - width / 2)*pixel_pitch;
    y_focalplane = (y_detector - height / 2)*pixel_pitch; 
    
end