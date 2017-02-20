clear all;
clc;
addpath(genpath('../libraries'));

%%
dataset_path = '/home/tulyakov/Desktop/espace-server/';
dataset_name = 'periapsis_orbit10';
set = DATASET_periapsisorb(dataset_path, dataset_name);

SCRIPT_search_folder(set);
SCRIPT_collect_sequences(set);
