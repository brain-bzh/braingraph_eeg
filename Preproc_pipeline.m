addpath Z:/fieldtrip-20160906/
addpath C:\Users\mmenoret\Documents\GitHub\braingraph_eeg

cfgpr.fold='D:/DATA/';
cfgpr.suj = 'ausa';
cfgpr.tache = 'naming';
cfgpr.segm=[-0.5 0.480];
cfgpr.xlsfile='D:/DATA/Comportement/STIM2.xlsx';

[dataclean] = func_preprocessing(cfgpr);

%Les ICA restent encore très parasités par certains bad channels - 
%Avant de lancer le preprocessing généralisé, il faut identifier les bad channels de chaque sujet puis retester le pipeline
