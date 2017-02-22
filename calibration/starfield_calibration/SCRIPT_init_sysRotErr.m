function SCRIPT_init_sysRotErr(set)

 %%

%dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'mcc_motor';
addpath(genpath('../libraries'));

%%
fprintf('Initializing systematic rotation error\n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

%%
R = eye(3,3); % no rotation
q = quaternion.rotationmatrix(R); 
Q = q.e;
sysRotErr = table(Q);
writetable(sysRotErr, set.sysRotErr0);  

end

