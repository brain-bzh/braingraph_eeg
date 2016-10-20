addpath Z:/fieldtrip-20160906/
addpath C:\Users\mmenoret\Documents\GitHub\braingraph_eeg

cfgpr.fold='C:/DATA/';
cfgpr.suj = 'brse';
cfgpr.tache = 'naming';
cfgpr.segm=[-0.5 0.48]; % ou valeur en s pour resting state (ex: 5)
cfgpr.xlsfile='D:/DATA/Comportement/STIM2.xlsx';
cfgpr.paramfold='D:/DATA/Comportement/';

[dataclean] = func_preprocessing(cfgpr);

%Les ICA restent encore très parasités par certains bad channels - 
%Avant de lancer le preprocessing généralisé, il faut identifier les bad channels de chaque sujet puis retester le pipeline
