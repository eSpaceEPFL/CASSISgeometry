%% param

clear all;
close all;

addpath(genpath('../mice'));
seq_fname = '/HDD1/Data/CASSIS/2016_11_01_MARS/level1/2016-11-22T16.01.10.635~2016-11-22T16.03.06.635.mat'
load(seq_fname)

kernel_fname = '/HDD1/Data/CASSIS/2016_12_14_CASSIS_KERNELS/mk/em16_ops_v130_20161202_001.tm'
cspice_furnsh(kernel_fname);

[frame, mask, time] = expSeq.getFrame(1, [1,2,3,4]);

image = expSeq.getImage(2);
figure; imshow(image)


time_str = datestr(time, 0);
et = cspice_str2et(time_str); % time in seconds from J2000

    
[ camid, found ] = cspice_bodn2c( 'TGO_CASSIS' );

[shape, dref, bsight, bounds] = cspice_getfov( camid, 4);

for i=1:4

    if( i <= 4 )
       fprintf( 'Corner vector %d\n\n', i)
       dvec = bounds(:,i);
    end

    if ( i == 5 )
        fprintf( 'Boresight vector\n\n' )
        dvec = bsight;
    end
 
          
%          Compute the surface intercept point using
%          the specified aberration corrections.
          
          [ spoint, trgepc, srfvec, found ] =                   ...
                         cspice_sincpt( 'Ellipsoid', 'Mars',         ...
                                        et, 'IAU_MARS', 'CN+S', ...
                                        'TGO', dref,   dvec );
                                    
          [ radius, lon, lat ] = cspice_reclat( spoint );
          lon_vec(i) = lon * cspice_dpr
          lat_vec(i) = lat * cspice_dpr 
                                    
                                    %          if( found )
% 
%             
%             Compute range from observer to apparent intercept.
%             
%             dist = vnorm( srfvec );
% 
%             
%             Convert rectangular coordinates to planetocentric
%             latitude and longitude. Convert radians to degrees.
%             
%             [ radius, lon, lat ] = cspice_reclat( spoint );
% 
%             lon = lon * cspice_dpr;
%             lat = lat * cspice_dpr;
% 
%             
%             Display the results.
%             
%             fprintf( '  Vector in %s frame = \n', dref )
%             fprintf( '   %18.10e %18.10e %18.10e\n', dvec );
% 
%             fprintf( [ '\n'                                              ...
%                        '  Intercept:\n'                                  ...
%                        '\n'                                              ...
%                        '     Radius                   (km)  = %18.10e\n' ...
%                        '     Planetocentric Latitude  (deg) = %18.10e\n' ...
%                        '     Planetocentric Longitude (deg) = %18.10e\n' ...
%                        '     Range                    (km)  = %18.10e\n' ...
%                        '\n' ],                                           ...
%                         radius,  lat,  lon,  dist                          )
%          else
%             disp( 'Intercept not found.' )
%          end

 end
      
imagesc(framelet);