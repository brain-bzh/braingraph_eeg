addpath Z:/GitHub\fieldtrip
addpath Z:\GitHub\braingraph_eeg

cfgpr.fold='W:/DATA/';
cfgpr.suj = 'romu';
cfgpr.tache = 'audio';
cfgpr.segm=[-0.5 1.043]; % ou valeur en s pour resting state (ex: 5)
cfgpr.xlsfile='W:/DATA/Comportement/STIM2.xlsx';
cfgpr.paramfold='W:/DATA/Comportement/';

[dataclean] = func_preprocessing(cfgpr);

%Les ICA restent encore très parasités par certains bad channels - 
%Avant de lancer le preprocessing généralisé, il faut identifier les bad channels de chaque sujet puis retester le pipeline
