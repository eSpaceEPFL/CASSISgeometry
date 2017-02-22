function [x_subexp, y_subexp] = cassis_sensor2subexp(x_sensor, y_sensor, x0, y0)
    
    x_subexp = x_sensor - x0 + 1;
    y_subexp = y_sensor - y0 + 1; 
    
end