function K = f_x0_y0_2K(f, x0, y0)
% Given intrinsic parameters computes intrinsic matrix.
if( length(f) > 1 )
    % fx ~= fy
    K = [f(1) 0 x0; 0 -f(2) y0; 0 0 1]; 
else
    % fx = fy
    K = [f 0 x0; 0 -f y0; 0 0 1];
end

end