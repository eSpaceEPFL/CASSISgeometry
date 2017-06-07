function [x_front, y_front] = cassis_sensor2virtual(x_sensor, y_sensor, height)
    
    x_front = x_sensor; % for cassis x coordinat is already flipped
    y_front = height - y_sensor + 1; 
    

end