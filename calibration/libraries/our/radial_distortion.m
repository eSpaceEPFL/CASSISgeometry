function [ output] = radial_distortion(params, input)
% vectior of parameteres [xc yc k1 k2 k3]
% vectior of inputs [x_ideal y_ideal]
% vectior of outputs [dx_dist dy_dist]
[xc, yc, k1, k2, k3] = deal(params(1), params(2), params(3), params(4), params(5));
[x_ideal, y_ideal] = deal(input(:,1), input(:,2));

r = sqrt((x_ideal-xc).^2+(y_ideal-yc).^2);
L = k1*r.^2 + k2*r.^4 + k3*r.^6;

x_dist = L.*(x_ideal-xc);
y_dist = L.*(y_ideal-yc);

output =[x_dist y_dist];
end

