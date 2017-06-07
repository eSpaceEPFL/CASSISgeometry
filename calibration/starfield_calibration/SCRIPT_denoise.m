% Script flattens images, substracts dark field, masks out problems

function SCRIPT_denoise(set)

%%
%dataset_path = '/home/tulyakov/Desktop/espace-server';
%dataset_name = 'pointing_cassis';
addpath(genpath('../libraries'));
lowSigmaDOG  = 7;
highSigmaDOG = 1;
gamma = 0.9;

%%
clc
fprintf('Substracting dark frame and DOG filtering\n');

% read folders structure
%set = DATASET_starfields(dataset_path, dataset_name);

% read exposures summary
expSummary = readtable(set.exposuresSummary);
unique_exp = unique(expSummary.exp_length);
nb_unique_exp = length(unique_exp);
nb_exp = height(expSummary);

fprintf('Computing dark frame for every exposure length\n');
for nunique_exp = 1:nb_unique_exp
    uniqueexpSummary = expSummary(unique_exp(nunique_exp) == (expSummary.exp_length),:);
    for nfile = 1:min(height(uniqueexpSummary),200)
        I = im2double(imread([set.raw_exposures '/' uniqueexpSummary.fname_exp{nfile}]));
        Istack(:,:,nfile) = I;
    end 
    Idark(:,:,nunique_exp) = median(Istack, 3);
    clear Istack;
end

fprintf('Substracting dark frame and DOG fitering\n');
%f = figure;
for nexp = 1:nb_exp
    
    fprintf('%s...\n', expSummary.fname_exp{nexp});
    ind = find((expSummary.exp_length(nexp)) == unique_exp);
    
    % substract dark frame
    I = im2double(imread([set.raw_exposures '/' expSummary.fname_exp{nexp}]));
    mask = im2double(imread([set.raw_exposures '/' expSummary.fname_mask{nexp}]));
    mask = imerode(mask,ones(21));
    I = max(I - Idark(:,:,ind),0);
        
    % DOG
    filter = fspecial('gaussian', [21, 21], highSigmaDOG) - fspecial('gaussian', [21, 21], lowSigmaDOG);
    I = (max(imfilter(I,filter),0)).^gamma;
    I = (I - min(I(:))) / range(I(:));
    I = I.*mask;
    I = imadjust(I,[0.05 1]);
    
    % save
    fname = [set.denoise_exposure '/' expSummary.fname_exp{nexp}];
    imwrite(uint16(I*2^16),fname); 
   
    % save visualization
    %figure(f); imshow(I*10);    
    %pause(0.1);
end


