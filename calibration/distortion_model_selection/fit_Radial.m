function param_vec = fit_Radial(xy_norm, ij_norm)

   options = optimoptions('lsqnonlin', 'Algorithm', 'levenberg-marquardt','Display','iter', 'MaxIter', 1000, 'TolFun',  1e-15, 'MaxFunEvals', 10000, 'TolX', 1e-15);
   param0 = [0 0 0 0 0 0 0]';
   fun = @(params) reshape(ij_norm - distort_radial(params, xy_norm),[],1);
   param_vec = lsqnonlin(fun, param0, [], [], options);

end 

