function R = angles2mat(alpha_x, alpha_y, alpha_z)
    % http://nghiaho.com/?page_id=846
    % all angle are in radian
	
    if( size(alpha_x,1) == 1)
        
        X = eye(3,3);
        Y = eye(3,3);
        Z = eye(3,3);
        
        X(2,2) = cos(alpha_x);
        X(2,3) = -sin(alpha_x);
        X(3,2) = sin(alpha_x);
        X(3,3) = cos(alpha_x);
        
        Y(1,1) = cos(alpha_y);
        Y(1,3) = sin(alpha_y);
        Y(3,1) = -sin(alpha_y);
        Y(3,3) = cos(alpha_y);
        
        Z(1,1) = cos(alpha_z);
        Z(1,2) = -sin(alpha_z);
        Z(2,1) = sin(alpha_z);
        Z(2,2) = cos(alpha_z);
        
        R = Z*Y*X;
        
    else
        nrot = size(alpha_x,1);
        R = zeros(3,3,nrot);
        for irot = 1:nrot
            R(:,:,irot) = angles2mat(squeeze(alpha_x(irot)), squeeze(alpha_y(irot)), squeeze(alpha_z(irot)));
        end
    end
end
