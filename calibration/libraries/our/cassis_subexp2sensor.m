function [x_sensor, y_sensor] = cassis_subexp2sensor(x_subexp, y_subexp, x0, y0)
    
    x_sensor = x_subexp + x0 - 1;
    y_sensor = y_subexp + y0 - 1; 
    
end