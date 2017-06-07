function dist = rational_model_sampson_error(param, xy, chi6D_ij)
% Compute sampson error for rational model with param and set of image
% correspondences xy and chi6_ij.
% For details refer Mutiple view Geometry by RIchard Hartley (p99)

% Sampson error = -F'*inv(J*trans(J))*F

% F(X) = A*f
% where A and f
% A*f = [0*chi_6D*Arow1' + -1*chi_6D*Arow2' + y*chi_6D*Arow3']
%       [1*chi_6D*Arow1' + 0*chi_6D*Arow2' + -x*chi_6D*Arow3']    
%       [-y*chi_6D*Arow1' + x*chi_6D*Arow2' + 0*chi_6D*Arow3']   
%     [  0 * chi_6D, -1 * chi_6D,  y * chi_6D; ]     [ Arow1' ]
% A = [  1 * chi_6D,  0 * chi_6D, -x * chi_6D; ] f = [ Arow2'  ] 
%     [ -y * chi_6D,  x * chi_6D,  0 *  chi_6D ]     [ Arow3'  ] 
% X = [ x, y, i, j ]

% J = dF / dX 
% J =  [Af_row1/dx Af_row1/dy Af_row1/di Af_row1/dj ]
%      [Af_row2/dx Af_row2/dy Af_row2/di Af_row3/dj ]
%      [Af_row3/dx Af_row3/dy Af_row3/di Af_row4/dj ]
% J = [ 0            , chi_6D*Arow3 , -1*dchi_6D/di*Arow2'+y*dchi_6D/di*Arow3', -1*dchi_6D/dj*Arow2'+y*dchi_6D/dj*Arow3']   
%     [-chi_6D*Arow3', 0            , 1*dchi_6D/di*Arow1'-x*dchi_6D/di*Arow3' , 1*dchi_6D/dj*Arow1'-x*dchi_6D/dj*Arow3',
%     [ chi_6D*Arow2', -chi_6D*Arow1, -y*dchi_6D/di*Arow1'+x*dchi_6D/di*Arow2',-y*dchi_6D/dj*Arow1'+x*dchi_6D/dj*Arow2']
% dchi_6D/di = [2*i j   0 1 0 0]
% dchi_6D/dj = [0   i 2*j 0 1 0]
  

npoints = size(xy,1);
[Arow1, Arow2, Arow3] = deal(param(1:6)', param(7:12)', param(13:end)');
for point_idx = 1:npoints
    
    [i, j] = deal(chi6D_ij(point_idx ,4), chi6D_ij(point_idx ,5));
    [x, y] = deal(xy(point_idx ,1), xy(point_idx ,1));
    
    dchi_6D_di = [2*i, j,   0, 1, 0, 0];
    dchi_6D_dj = [0  , i, 2*j, 0, 1, 0];
    
    % A*f = [0*chi_6D*Arow1' + -1*chi_6D*Arow2' + y*chi_6D*Arow3']
    %       [1*chi_6D*Arow1' + 0*chi_6D*Arow2' + -x*chi_6D*Arow3']
    %       [-y*chi_6D*Arow1' + x*chi_6D*Arow2' + 0*chi_6D*Arow3']
    
    A = [0*chi6D_ij(point_idx,:),                 -1*chi6D_ij(point_idx,:),                xy(point_idx,2).*chi6D_ij(point_idx,:);...
        1*chi6D_ij(point_idx,:),                  0*chi6D_ij(point_idx,:),                -xy(point_idx,1).*chi6D_ij(point_idx,:);...
        -xy(point_idx,2).*chi6D_ij(point_idx,:),  xy(point_idx,1).*chi6D_ij(point_idx,:), 0*chi6D_ij(point_idx,:)];
    
    F = A*param;
    
    % J = [ 0            , chi_6D*Arow3 , -1*dchi_6D/di*Arow2'+y*dchi_6D/di*Arow3', -1*dchi_6D/dj*Arow2'+y*dchi_6D/dj*Arow3']
    %     [-chi_6D*Arow3', 0            , 1*dchi_6D/di*Arow1'-x*dchi_6D/di*Arow3' , 1*dchi_6D/dj*Arow1'-x*dchi_6D/dj*Arow3',
    %     [ chi_6D*Arow2', -chi_6D*Arow1, -y*dchi_6D/di*Arow1'+x*dchi_6D/di*Arow2',-y*dchi_6D/dj*Arow1'+x*dchi_6D/dj*Arow2']
    
    J = [ 0                          , chi6D_ij(point_idx,:)*Arow3' , -1*dchi_6D_di*Arow2'+y*dchi_6D_di*Arow3', -1*dchi_6D_dj*Arow2'+y*dchi_6D_dj*Arow3';...
        -chi6D_ij(point_idx,:)*Arow3', 0                            ,  1*dchi_6D_di*Arow1'-x*dchi_6D_di*Arow3',  1*dchi_6D_dj*Arow1'-x*dchi_6D_dj*Arow3';...
         chi6D_ij(point_idx,:)*Arow2', -chi6D_ij(point_idx,:)*Arow1', -y*dchi_6D_di*Arow1'+x*dchi_6D_di*Arow2', -y*dchi_6D_dj*Arow1'+x*dchi_6D_dj*Arow2'];
      
    dist(point_idx,:) = -J'*inv(J*J')*F; 
end

end