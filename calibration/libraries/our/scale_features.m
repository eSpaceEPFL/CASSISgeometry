function [vec_norm, T] = scale_features(vec)
    % normalize homogeneous feature vector, so that each dimension of the 
    % vector has zero mean and standard deviaton sqrt(2)
    % vec is N x M, were each row is observation.  
    % T is N x N transformation, vec_norm = vec*T'
    
    % Note, that vector should be homogenious. I.e. lase element of every row 
    % should be 1.
       
    if( nnz(vec(:,end) ~= ones(size(vec,1), 1)) )
        error('Error: vec should be homogenious..');
    end
            
    [~, mu, sigma] = zscore(vec(:,1:end-1));
    
    % In iv vec has just 3 columns, T is 
    %     [ sqrt(2)/sigma_col1   ,  0                    ,  0 ]
    % T = [ 0                    ,  sqrt(2)/sigma_col2   ,  0 ]
    %     [ -M*sqrt(2)/sigma_col1,  -M*sqrt(2)/sigma_col2,  1 ]
    T = diag([sqrt(2)./sigma 1]);
    T(end,1:end-1) = -mu./sigma.*sqrt(2); 
    T = T';
    
    vec_norm = vec*T';    
end
    
