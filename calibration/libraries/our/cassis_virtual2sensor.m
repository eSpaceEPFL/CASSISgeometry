function [x_sensor, y_sensor] = cassis_virtual2sensor(x_front, y_front, height)
    
    x_sensor = x_front; % for cassis x coordinat is already flipped
    y_sensor = height - y_front + 1; 
    
end