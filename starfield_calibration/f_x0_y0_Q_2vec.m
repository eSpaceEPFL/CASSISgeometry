function vec = f_x0_y0_Q_2vec(f, x0, y0, Q)
% Given number of parameters itput everything in one vector
vec = [f(:); x0; y0; Q(:)];
end