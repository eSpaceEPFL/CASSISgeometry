function huber = huber_cost(err, th)
% huber cost function implemented as suggested in Multiview Geometry (p619)
% err- is signed error 
% th - is threhold, that approximately corresponds to outlier threshold 
abs_err = abs(err);
ind = abs_err > th;
huber = err.^2;
huber(ind) = 2*th*abs_err(ind) - th*th;
end