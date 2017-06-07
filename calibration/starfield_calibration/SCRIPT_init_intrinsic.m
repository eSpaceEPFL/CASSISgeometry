function SCRIPT_init_intrinsic(set)

 %%

%dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));

%%
fprintf('Initializing intrinsic to camera specs\n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

%%
f = 880;   % mm
x0 = 1024; % pix
y0 = 1024;
pixSize = 10e-6;
intrinsic0 = table(f, x0, y0, pixSize);
writetable(intrinsic0, set.intrinsic0);  

end

