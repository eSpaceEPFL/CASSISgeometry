clear all;
clc;
addpath(genpath('../libraries'));
diary on;


%smb://ctsgenas1/

%%
dataset_path = '/home/tulyakov/Desktop/espace-server/';
dataset_name = 'periapsis_orbit10';
set = DATASET_periapsisorb(dataset_path, dataset_name);

% search sequence files
SCRIPT_search_folder(set);

% collect sequences
SCRIPT_collect_sequences(set);

% save sequences
SCRIPT_stich_framelets(set);