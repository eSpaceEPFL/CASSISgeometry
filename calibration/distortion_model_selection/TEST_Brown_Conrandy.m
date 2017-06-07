% 2015-06-23
% Try to fit calibration data from CASSIS to Brown-Conrady distiortion
% model
% "Lens distortion for close-range photogrammetry" by J. G. Fryer
% r = sqrt((xc - x)^2+(yc - y)^2)
% Radial: dx_r=(x-xc)*(k_1*r^2+k_2*r_^4+k_2*r_^4 )  - symmetric distortion
% Tangential: dx_t=p_1*(r^2+2*(x-xc)^2 )+2*p_2*(x-xc)*(y-yc) - decentering distortion

pixel_size = 10e-6;
width = 2048;
height = 2048;
image_size = [height width];
exel_filename  = 'Optical-distortion-predict.xlsx';

exel_tab = xlsread(exel_filename);

% 3rd & 4th columns are distorted x & y coordinates
% 5th & 6th columns are undistorted x & y coordinates
x_dist = exel_tab(1:25,3)*1e-3;
y_dist = exel_tab(1:25,4)*1e-3;
x_ideal = exel_tab(1:25,5)*1e-3;
y_ideal = exel_tab(1:25,6)*1e-3;

x_dist = x_dist / pixel_size / (height+width);
y_dist = y_dist / pixel_size / (height+width);
x_ideal =x_ideal / pixel_size / (height+width);
y_ideal = y_ideal / pixel_size / (height+width);

PREDICTOR = [x_ideal y_ideal];
RESPONSE = [x_dist y_dist];

% cost function (MSE) in normalized coordinates and in pixels
cost_fun_pix = @(params, PREDICTOR, RESPONSE)   mean(sqrt(sum( ((RESPONSE - distort_brown_conrandy(params, PREDICTOR) ).^2).*(height+width).^2, 2)));

% find optimal params
param = fit_Brown_Conrandy(PREDICTOR, RESPONSE);

% perform 10-fold test
fun = @(XTRAIN, YTRAIN, XTEST, YTEST) cost_fun_pix(fit_Brown_Conrandy(XTRAIN, YTRAIN), XTEST, YTEST);
mrse = crossval(fun, PREDICTOR, RESPONSE, 'Leaveout', 1);

% plot distortion field 
[i, j, x, y] = simulate_distortion_field(@distort_brown_conrandy, param, image_size);
visualize_vector_field(i, j, x, y);
hold on; plot(param(1), param(2),'o');
set(gca, 'ydir', 'reverse');
%title(['Distorted - to - Undistorted Field'  sprintf(' (RMSE = %0.3f)', mean(mrse))]);

