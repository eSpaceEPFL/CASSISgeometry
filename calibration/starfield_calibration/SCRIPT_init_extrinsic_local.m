function SCRIPT_init_extrinsic_local(dataset_name)
 %%

dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));

%%
clc
fprintf('Improving rotation for each image individually, while keeping focal length fixed\n');

% read folders structure
set = DATASET_starfields(dataset_path, dataset_name);

% read stars 
inlierStarSummary = readtable(set.inlierStarSummary);

% read intrinsics
intrinsic0 = readtable(set.intrinsic0);
f  = intrinsic0.f;
x0 = intrinsic0.x0;
y0 = intrinsic0.y0;
pixSize = intrinsic0.pixSize;

% read extirinsic
extrinsic0 = readtable(set.extrinsic0_spice);
nb_exp = height(extrinsic0);

% improve rotation angles for each image
i = 1;
for nexp = 1:nb_exp

    % get all point for current exposure
    pointId = find(cassis_time2num(extrinsic0.time{nexp}) == cassis_time2num(inlierStarSummary.time));
    nb_points = length(pointId);
    if nb_points  == 0 
       fprintf('%s: %i points \n', extrinsic0.time{nexp}, nb_points);
       continue;
    end
    
    % fill initial quaternions
    Q = [extrinsic0.Q_1(nexp) extrinsic0.Q_2(nexp) extrinsic0.Q_3(nexp) extrinsic0.Q_4(nexp)];

    % set initial solution
    sol0 = Q;

    % get points for current image
    [XX(:,1), XX(:,2), XX(:,3)] = ...
    raDec2XYZ(deg2rad(inlierStarSummary.ra(pointId)), deg2rad(inlierStarSummary.dec(pointId)));    
    xx(:,1) = inlierStarSummary.x(pointId);
    xx(:,2) = inlierStarSummary.y(pointId); 

    % optimize
    fun = @(sol) clc_res(sol, f, x0, y0, pixSize, xx, XX);
    options = optimoptions('lsqnonlin', 'Algorithm',  'levenberg-marquardt', 'StepTolerance', 1e-10, 'Display', 'off',  'MaxIter', 30);
    res0 = clc_res(sol0, f, x0, y0, pixSize, xx, XX);
    [sol, ~, res] = lsqnonlin(fun, sol0, [], [], options);
    avgErr0(i) = mean(sqrt(sum(reshape(res0, nb_points, 2).^2,2)));
    avgErr(i) = mean(sqrt(sum(reshape(res, nb_points, 2).^2,2)));
    
    fprintf('%s: %i points, err0: %d, err %d \n', extrinsic0.time{nexp}, nb_points, avgErr0(i), avgErr(i));
    
    % retrive solution
    Q = sol;
    extrinsic0.Q_1(nexp) = Q(1);
    extrinsic0.Q_2(nexp) = Q(2);
    extrinsic0.Q_3(nexp) = Q(3);
    extrinsic0.Q_4(nexp) = Q(4);
    clear XX xx;
    i = i + 1;
end

fprintf('Average error with SPICE parameters %d \n', mean(avgErr0));
fprintf('Average error after updating angles for every image %d \n', mean(avgErr));
    
writetable(extrinsic0, set.extrinsic0_local);  

end

function err = clc_res(sol, f, x0, y0, pixSize, xx, XX)
    
    nb_points = size(xx,1);
     
    K = f_x0_y0_2K(f, x0, y0, pixSize);

    % precompute rotation matrices for speed
    Qcur = quaternion(sol);
    R = RotationMatrix(Qcur);
    
    % compute Euclidian image error
    point_err = stars2image_error( XX, xx, R, K);
    err = reshape(point_err,[],1);
end




