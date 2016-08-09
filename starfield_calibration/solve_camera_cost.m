function err = solve_camera_cost(sol, XYZ_index, xy_field, imageIdx, nb_times)
    
    nb_points = size(XYZ_index,1);
    
    [f, x0, y0, angles] = vec2_f_x0_y0_angles(sol, nb_times);
    K = f_x0_y0_2K(f, x0, y0);
    R = angles2mat(angles(1,:)', angles(2,:)', angles(3,:)');
    
    err = [];
    for npoint = 1:nb_points
        point_err = point_cost(XYZ_index(npoint,:), xy_field(npoint,:), K, R(:,:,imageIdx(npoint)));
        err = [err; norm(point_err(:))];
    end
        
end

function err = point_cost(XYZ_index, xy_field, K, R)

    % compute P
    xyz_index = K*R*XYZ_index';
    x_tilda =(xyz_index(1,:))./(xyz_index(3,:));
    y_tilda =(xyz_index(2,:))./(xyz_index(3,:));
    err = [x_tilda-xy_field(1) y_tilda-xy_field(2)];
   
end
