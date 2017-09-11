function K = f_x0_y0_2K(f, x0, y0, pixSize)
% Given intrinsic parameters computes intrinsic matrix.
 
f = f*1e-3;
if( length(f) > 1 )
    % fx ~= fy
    K = [f(1)/pixSize 0 x0; 0 f(2)/pixSize y0; 0 0 1]; 
else
    % fx = fy
    K = [f/pixSize 0 x0; 0 f/pixSize y0; 0 0 1];
end

end