function A_vec = fit_rational_function_inverse(ij_norm, xy_norm)
% To initialize the solution we use SVD trick and later refine the solution
% using nonlinear optimization as recommended in Multiple View Geometry by
% Richard Hartley

chi6D_ij_norm = lift2D_to_6D(ij_norm);

% find initial solution
A0_vec = estimate_rational_matrix_6_points(xy_norm, chi6D_ij_norm);

% improve soution by nonlinear optimization
% define cost function
fun = @(param) reshape(rational_model_sampson_error(param/param(end), xy_norm, chi6D_ij_norm),[],1)
options = optimoptions('lsqnonlin', 'Algorithm', 'levenberg-marquardt','DIsplay','iter', 'MaxIter', 1000, 'TolFun',  1e-15, 'MaxFunEvals', 10000, 'TolX', 1e-15);
A_vec = lsqnonlin(fun, A0_vec, [], [], options);
A_vec = A_vec/A_vec(end);

end 
