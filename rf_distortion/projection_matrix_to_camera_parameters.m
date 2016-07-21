function [R, K] = projection_matrix_to_camera_parameters(P)

% Function computes parameters of the camera, given camera projection
% matrix (translation we assume equal to zero), for details reffer:
% [1] Computer Vision A Modern Approach by Forsyth, p45-46
% [2] Multiple View Geometry by Hartleym, p163
% P = K*R, R - is orthonormal, K - is upprediagonal
% P is 4x3 matrix P = K*[R|-RC] 

% Example
% P=[ 3.5e2 3.4e2   2.8e2  -1.4e6;
%    -1.0e2 2.3e1   4.6e2  -6.3e5;
%    7.1e-1 -3.5e-1 6.1e-1 -9.2e2];

[K, R]=rq(P(:,1:3));

% standart form for K matrix
%     [ p x x ]
% K = [ 0 p x ] p - is positive elements
%     [ 0 0 1 ]
sign_K11 = sign(K(1,1));
sign_K22 = sign(K(2,2));
sign_K33 = sign(K(3,3));
W = [sign_K11 0 0; 0 sign_K22 0; 0 0 sign_K33];
K=K*W;
R=W*R;

K = K./K(end); 

end
