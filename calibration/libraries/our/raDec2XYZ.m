function [X,Y,Z] = raDec2XYZ(ra, dec)
% Convert equatiorial coordinates (in radian) to rectangular
X = cos(ra).*cos(dec);
Y = sin(ra).*cos(dec);
Z = sin(dec);

end