function [f, x0, y0, angle] =  vec2_f_x0_y0_angles(vec, n)

% Given parameters vector, returns parameters
if( length(vec) - n*3 - 2 == 1 ) 
    % single f
    [f, x0, y0, angle] = deal(vec(1), vec(2), vec(3), vec(4:end));
else
    % fx and fy
    [f, x0, y0, angle] = deal(vec(1:2), vec(3), vec(4), vec(5:end));
end
angle = reshape(angle, 3, []); 
end