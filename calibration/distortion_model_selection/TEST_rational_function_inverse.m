% 2015-09-15
% Try to fit data from CASSIS to rational undistortion model 
% from "A Rational Function Lens Distortion Model for General Cameras" by
% Devid Claus
% chi_6 = [x_d^2 x_d*y_d y_d^2 x_d y_d 1]^T
% x = A_row1*chi_6 / A_row3*chi_6 
% y = A_row2*chi_6 / A_row3*chi_6                      

% rmse = 0.0887

clear all;
pixel_size = 10e-6;
width = 2048;
height = 2048;
image_size = [height width];
exel_filename  = 'Optical-distortion-predict.xlsx';

exel_tab = xlsread(exel_filename);

% 3rd & 4th columns are distorted x & y coordinates
% 5th & 6th columns are undistorted x & y coordinates
i = exel_tab(1:25,3)*1e-3;
j = exel_tab(1:25,4)*1e-3;
x = exel_tab(1:25,5)*1e-3;
y = exel_tab(1:25,6)*1e-3;
num = length(y);

i = i / pixel_size / (width+height);
j = j / pixel_size / (width+height);
x = x / pixel_size / (width+height);
y = y / pixel_size / (width+height);

PREDICTOR = [i j];
RESPONSE = [x y];

% cost function (MSE) in normalized coordinates and in pixels
cost_fun_pix = @(params, PREDICTOR, RESPONSE) mean2((RESPONSE - undistort_rational_function(params, PREDICTOR) ).^2.*(width+height).^2);

% fit model 
param = fit_rational_function_inverse(PREDICTOR, RESPONSE);

% perform leave-one-out test
fun = @(XTRAIN, YTRAIN, XTEST, YTEST) cost_fun_pix(fit_rational_function_inverse(XTRAIN, YTRAIN), XTEST, YTEST);
mrse = crossval(fun, PREDICTOR, RESPONSE, 'Leaveout', 1);

% plot distortion field 
[x, y, i, j] = simulate_distortion_field(@undistort_rational_function, param, image_size);
visualize_vector_field(i, j, x, y);
axis([0 2048 0 2048]);
set(gca, 'ydir', 'reverse');
set(gca,'xaxislocation','top');
grid on;
hold off;

% save result
A_rf = [param(1:6)'; param(7:12)'; param(13:end)'];
save('rational_function_canonical.mat', 'A_rf');
fprintf('mrse = %0.4d', mean(mrse));

