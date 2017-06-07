function SCRIPT_init_extrinsic_local(set)
 %%

%dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));

%%
clc
fprintf('Improving rotation for each image individually, while keeping focal length fixed\n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

% read stars 
inlierStarSummary = readtable(set.inlierStarSummary);

% read commands
rotCommands = readtable(set.rotCommand);
%for n = 1:height(inlierStarSummary )
%    idx = find(cassis_time2num(inlierStarSummary.time(n)) == cassis_time2num(rotCommands.time));
%    angle(n) = round(rotCommands.angle(idx));
%end

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
angle_diff = [];
text_ = {};
for nexp = 1:nb_exp

    % get all point for current exposure
    text_{nexp} = extrinsic0.time{nexp};
    
    rotId = find(cassis_time2num(extrinsic0.time{nexp}) == cassis_time2num(rotCommands.time));
    angle(nexp) = rotCommands.angle(rotId);
    
    pointId = find(cassis_time2num(extrinsic0.time{nexp}) == cassis_time2num(inlierStarSummary.time));
    nb_points = length(pointId);
    if nb_points  == 0 
       fprintf('%s: %i points \n', extrinsic0.time{nexp}, nb_points);
       continue;
    end
    
    % fill initial quaternions
    Q0 = [extrinsic0.Q_1(nexp) extrinsic0.Q_2(nexp) extrinsic0.Q_3(nexp) extrinsic0.Q_4(nexp)];
    q0 = quaternion( Q0 );
    
    % set initial solution
    sol0 = Q0;

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
    avgErr0(nexp) = mean(sqrt(sum(reshape(res0, nb_points, 2).^2,2)));
    avgErr(nexp) = mean(sqrt(sum(reshape(res, nb_points, 2).^2,2)));
    
    fprintf('%s: %i points, err0: %d, err %d \n', extrinsic0.time{nexp}, nb_points, avgErr0(nexp), avgErr(nexp));
    
    % normalize and make sure that first componets is positive
    q = normalize( quaternion(sol) );
    Q = q.e;
    Q =  Q*sign(Q(1));
    q = quaternion(Q);
    
    % compute difference between new and old quaternion
    q_diff = ldivide(q0, q);
    [angle_diff(nexp), ~] = AngleAxis(q_diff); 
     angle_diff(nexp) = rad2deg(angle_diff(nexp));   
    
    extrinsic0.Q_1(nexp) = Q(1);
    extrinsic0.Q_2(nexp) = Q(2);
    extrinsic0.Q_3(nexp) = Q(3);
    extrinsic0.Q_4(nexp) = Q(4);
    clear XX xx;
    i = i + 1;
end

f = figure('units','normalized','outerposition',[0 0 1 1]);
angle_diff = min(abs(angle_diff), abs(angle_diff-360));
plot(angle_diff,'-bx');
xlabel('time')
ylabel('Anglular Diff., [deg]')
ax = gca;
ax.XTickLabel =text_;
hgexport(f, set.local_vs_spice_angel_diff_IMG,  ...
     hgexport('factorystyle'), 'Format', 'png');

f = figure('units','normalized','outerposition',[0 0 1 1]);
plot(avgErr0,'-ro'); hold on;
plot(avgErr,'-g+');
ylabel('projection error, [pix]')
legend({'Proj. Err. SPICE', 'Proj. Err. Local Adjustment'})
xlabel('time')
ax = gca;
ax.XTickLabel =text_;
hgexport(f, set.local_vs_spice_angel_diff_IMG,  ...
     hgexport('factorystyle'), 'Format', 'png');

f = figure('units','normalized','outerposition',[0 0 1 1]);
yyaxis left
plot(angle,'-r'); hold on;
ylabel('Commanded angle, [deg]')
yyaxis right
plot(angle_diff,'-g'); 
ylabel('Angular difference, [deg]')
xlabel('time')
legend({'Commanded angle, [deg]', 'Angular difference, [deg]'})
ax = gca;
ax.XTickLabel =text_;
hgexport(f, set.ange_vs_angel_diff_IMG,  ...
     hgexport('factorystyle'), 'Format', 'png');
 
fprintf('Average error with SPICE parameters %d \n', median(avgErr0));
fprintf('Average error after updating angles for every image %d \n', median(avgErr));
    
writetable(extrinsic0, set.extrinsic0_local);  

end

function err = clc_res(sol, f, x0, y0, pixSize, xx, XX)
    
    nb_points = size(xx,1);
     
    K = f_x0_y0_2K(f, x0, y0, pixSize);

    % precompute rotation matrices for speed
    Qcur = quaternion(sol);
    Qcur = normalize( Qcur );
    R = RotationMatrix(Qcur);
    
    % compute Euclidian image error
    point_err = stars2image_error( XX, xx, R, K);
    err = reshape(point_err,[],1);
end




