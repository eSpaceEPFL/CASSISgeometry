function [x_detector, y_detector] = cassis_focalplane2detector(x_focalplane, y_focalplane, width, height, pixel_pitch)
    
    % convert detector coordinates to focal plane coordinates
    x_detector = (x_focalplane / pixel_pitch + width / 2);
    y_detector = (y_focalplane / pixel_pitch + height / 2); 
    
end