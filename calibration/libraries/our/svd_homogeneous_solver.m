function f = svd_homogeneous_solver(A)

    % Solve homogenious system of linear equations
    % A*f = 0, subject to ||f|| = 1, using svd trick recommended in  
    % Multiple View Geometry by Richard Hartley (p91)
    
    % Note, that 
    % (1) it is better to use feature vector normalization
    % and before constructing A.
    % (2) in number of linear independent equation is less than number of
    % unknowns solution is undefined f = []; 
    
    % Example
    % A = [2 -1.1; 0.21 -0.102; -1.01 0.5];
    % f = svd_homogeneous_solver(A);
      
    [~, ~, v] = svd(A,'econ');   
    f = v(:,end);        
end
    
