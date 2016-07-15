function vec = f_x0_y0_angles_2vec(f, x0, y0, angles)
% Given number of parameters itput everything in one vector
vec = [f(:); x0; y0; angles(:)];
end