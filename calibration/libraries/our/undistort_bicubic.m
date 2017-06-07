function [ output_args ] = undistort_bicubic(params, input)
    % vectior of parameteres [A_row1; A_row2]
    % vectior of inputs [x_dist y_dist]
    % vectior of outputs [x_undist y_undist]
    [A_row1, A_row2] = deal(params(1:10), params(11:end));
    [x_dist, y_dist] = deal(input(:,1), input(:,2));
    npoints = size(x_dist,1);
    chi = lift2D_to_10D([x_dist y_dist]);
    output_args = [(chi(:,1:10)*A_row1) (chi(:,1:10)*A_row2)]; 
end
