function [lat, lon] = getPixLatLon(x, y, timenum)
% Function return lat / lon for pixels centers with the specific coordinates. 
% Note that Spice Kernels should be already loaded
%
%

% This parameters can be read from ik
f = 880e-3;
pixsize = 10e-6;
x0 = 1024.5;
y0 = 1024.5;

% time
time_str = datestr(timenum, 0);
et = cspice_str2et(time_str); % time in seconds from J2000

[ camid, found ] = cspice_bodn2c( 'TGO_CASSIS' );
[shape, dref, bsight, bounds] = cspice_getfov( camid, 4);

% get vector that corresponds to pixel
Xcam = (x(:) - 0.5 - x0)*pixsize/f; 
%Ycam = (-(y(:) - 0.5) + y0)*pixsize/f;

Ycam = (y(:) - 0.5 - y0)*pixsize/f;

Zcam = ones(size(x(:)));

for i = 1:length(Xcam)
    dvec = [Xcam(i); Ycam(i); Zcam(i)];

[ spoint, trgepc, srfvec, found ] =                   ...
                         cspice_sincpt( 'Ellipsoid', 'Mars',         ...
                                        et, 'IAU_MARS', 'CN+S', ...
                                        'TGO', dref,   dvec );
                                    
[ radius, lon, lat ] = cspice_reclat( spoint );
lon_vec(i) = lon * cspice_dpr;
lat_vec(i) = lat * cspice_dpr; 
          
end

lon = reshape(lon_vec, size(x));
lat = reshape(lat_vec, size(x));

end