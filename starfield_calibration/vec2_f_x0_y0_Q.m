function [f, x0, y0, Q] =  vec2_f_x0_y0_Q(vec, n)

% Given parameters vector, returns parameters
if( length(vec) - n*4 - 2 == 1 ) 
    % single f
    [f, x0, y0, Q] = deal(vec(1), vec(2), vec(3), vec(4:end));
else
    % fx and fy
    [f, x0, y0, Q] = deal(vec(1:2), vec(3), vec(4), vec(5:end));
end
Q = reshape(Q, 4, []); 
end