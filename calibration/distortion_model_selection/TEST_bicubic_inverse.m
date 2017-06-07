% 2015-07-214
% Try to fit calibration data from CASSIS to bicubic undistortion model 
% from "Compensation of systematic errors of image and model coordinates" by
% Kilpel�
% Note that this is forward model
% chi_10 = [x.^3 x.^2.*y x.*y.^2 y.^3 x.^2 x.*y y^2 x y];
% i = A_row1*chi_10
% j = A_row2*chi_10                      

% rmse = 0.0167

addpath(genpath('../libraries'));

clear all;
pixel_size = 10e-6;
width = 2048;
height = 2048;
exel_filename  = 'Optical-distortion-predict.xlsx';
image_size = [height width];
exel_tab = xlsread(exel_filename);

% 3rd & 4th columns are distorted x & y coordinates
% 5th & 6th columns are undistorted x & y coordinates
x_dist = exel_tab(1:25,3)*1e-3;
y_dist = exel_tab(1:25,4)*1e-3;
x_ideal = exel_tab(1:25,5)*1e-3;
y_ideal = exel_tab(1:25,6)*1e-3;

x_dist  = x_dist  / pixel_size / (height+width);
y_dist  = y_dist  / pixel_size / (height+width);
x_ideal = x_ideal / pixel_size / (height+width);
y_ideal = y_ideal / pixel_size / (height+width);

PREDICTOR = [x_dist y_dist];
RESPONSE = [x_ideal y_ideal];

% cost function (MSE) in normalized coordinates and in pixels
cost_fun_pix = @(params, PREDICTOR, RESPONSE)   mean(sqrt(sum((RESPONSE - undistort_bicubic(params, PREDICTOR) ).^2.*(width+height).^2, 2)));

% fit model 
param = fit_bicubic_inverse(PREDICTOR, RESPONSE);

% perform leave-one-out test
fun = @(XTRAIN, YTRAIN, XTEST, YTEST) cost_fun_pix(fit_bicubic_inverse(XTRAIN, YTRAIN), XTEST, YTEST);
mrse = crossval(fun, PREDICTOR, RESPONSE, 'Leaveout', 1);

% plot distortion field 
[x, y, i, j] = simulate_distortion_field(@undistort_bicubic, param, image_size);
visualize_vector_field(i, j, x, y);
set(gca, 'ydir', 'reverse');
%title(['Distorted - to - Undistorted Field'  sprintf(' (RMSE = %0.3f)', mean(mrse))]);

% save result
A_b = [param(1:10)'; param(11:end)'];
save('bicubic_canonical.mat', 'A_b');
fprintf('mrse = %0.4d', mean(mrse));
