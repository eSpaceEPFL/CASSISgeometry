function [alpha_x, alpha_y, alpha_z] = mat2angles(R)
    % http://nghiaho.com/?page_id=846
    % alpha_x (-pi pi)
    % alpha_y (-pi/2 pi/2)
    % alpha_z (-pi pi)
    % all angle are in radian
    if( ndims(R) == 2 )
        alpha_x = atan2(R(3,2), R(3,3));
        alpha_y = atan2(-R(3,1), sqrt(R(3,2)*R(3,2) + R(3,3)*R(3,3)));
        alpha_z = atan2(R(2,1), R(1,1));
    else
        nrot = size(R,3);
        alpha_x = zeros(nrot,1);
        alpha_y = zeros(nrot,1);
        alpha_z = zeros(nrot,1);
        for irot = 1:nrot
            [alpha_x(irot), alpha_y(irot), alpha_z(irot)] = mat2angles(squeeze(R(:,:,irot)));
        end
    end
    
    
end
