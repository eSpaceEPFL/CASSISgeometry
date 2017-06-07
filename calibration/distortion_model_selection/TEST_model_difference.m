
clear all;

load('simulation_rational_model.mat');
A_sim = A_rf; clear A_rf
A_star = table2array(readtable('starField_rational_model.csv'));
image_size = [2048 2048]

err_opt = 1e10
for t  = 500:-1:-500
    
    A_sim_vec = [ A_sim(1,:)'; A_sim(2,:)'; A_sim(3,:)'];
    A_star_vec = [ A_star(1,:)'; A_star(2,:)'; A_star(3,:)'];

    [x1, y1, i1, j1] = simulate_distortion_field(@undistort_rational_function, A_sim_vec, image_size,0);
    [x2, y2, i2, j2] = simulate_distortion_field(@undistort_rational_function, A_star_vec, image_size,t);

     err = mean(sqrt((x2(:) - x1(:)).^2 + (y2(:) - y1(:)).^2));
     if err < err_opt
         err_opt = err
         t_opt = t
     end
end
    
visualize_vector_field(i1, j1, i1+x1-x2, j1+y1-y2);
axis([0 2048 0 2048]);
set(gca, 'ydir', 'reverse');
set(gca,'xaxislocation','top');
grid on;
hold off;