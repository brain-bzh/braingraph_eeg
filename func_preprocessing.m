function [dataclean] = func_preprocessing(cfgpr)
% Ouvre les données raw et fait le preprocessing (segmentation, filtres)
% fold = 'D:\DATA\'; ou fold='C:\DATA\';
% suj : nom du sujet (dossier)
% tache: nom de la tache ('naming','resting_state')
% segm : si tache [beg end] en secondes / si resting state nb secondes pour
% segments (2)

fold_s = [cfgpr.fold cfgpr.suj '\' cfgpr.tache '\'];
%fold = ['/homes/mmenoret/Data/BrainGraph_raw/' suj '/raw/' tache '/'];
file = dir(fullfile(fold_s,'*.raw'));
infile = fullfile(fold_s,file.name);

cfg=cfgpr; 
cfg.dataset = infile;

% Determiner trial en fonction events (ou segmenter pour resting state)
if strcmp(cfgpr.tache,'resting_state');
    cfg.trialdef.triallength = 5;
    cfg.trialdef.ntrials     = Inf;
    cfg.continuous  = 'yes';
    cfg = ft_definetrial(cfg);
else 
    cfg.trialfun   = 'ft_trialfun_braingraph_new';% enleve 2500 aux valeurs des trigger (0 = onset picture)
    cfg.trialdef.prestim    = -cfgpr.segm(1);
    cfg.trialdef.poststim   = cfgpr.segm(2);
    cfg = ft_definetrial(cfg);
    trl=cfg.trl;
end

% Jump artifact detection
    cfg            = [];
    cfg.trl        = trl;
    cfg.datafile   = infile;
    cfg.headerfile = infile;
    % channel selection, cutoff and padding
    cfg.artfctdef.zvalue.channel    = 'all';
    cfg.artfctdef.zvalue.cutoff     = 60;
    cfg.artfctdef.zvalue.trlpadding = 0;
    cfg.artfctdef.zvalue.artpadding = 0;
    cfg.artfctdef.zvalue.fltpadding = 0;
    % algorithmic parameters
    cfg.artfctdef.zvalue.cumulative    = 'yes';
    cfg.artfctdef.zvalue.medianfilter  = 'yes';
    cfg.artfctdef.zvalue.medianfiltord = 9;
    cfg.artfctdef.zvalue.absdiff       = 'yes';
    % make the process interactive
    cfg.artfctdef.zvalue.interactive = 'yes';
    [cfg, artifact_jump] = ft_artifact_zvalue(cfg);

% Muscle artifact detection
    cfg            = [];
    cfg.trl        = trl;
    cfg.datafile   = infile;
    cfg.headerfile = infile;
   % channel selection, cutoff and padding
    cfg.artfctdef.zvalue.channel = 'all';
    cfg.artfctdef.zvalue.cutoff      = 30;
    cfg.artfctdef.zvalue.trlpadding  = 0;
    cfg.artfctdef.zvalue.fltpadding  = 0;
    cfg.artfctdef.zvalue.artpadding  = 0.1;
  % algorithmic parameters
    cfg.artfctdef.zvalue.bpfilter    = 'yes';
    cfg.artfctdef.zvalue.bpfreq      = [110 140];
    cfg.artfctdef.zvalue.bpfiltord   = 9;
    cfg.artfctdef.zvalue.bpfilttype  = 'but';
    cfg.artfctdef.zvalue.hilbert     = 'yes';
    cfg.artfctdef.zvalue.boxcar      = 0.2;
  % make the process interactive
    cfg.artfctdef.zvalue.interactive = 'yes';
   [cfg, artifact_muscle] = ft_artifact_zvalue(cfg);
   
   % rejet artefacts
    cfg            = [];
    cfg.trl        = trl;
    cfg.datafile   = infile;
    cfg.headerfile = infile;
    cfg.artfctdef.reject          = 'complete'%'complete' (default = 'complete')
    %cfg.artfctdef.minaccepttim    =                      
    %cfg.artfctdef.crittoilim      = %when using complete rejection, reject  trial only when artifacts occur within this time window (default = whole trial)
    %cfg.artfctdef.eog.artifact    = artifact_eog;
    cfg.artfctdef.jump.artifact   = artifact_jump;
    cfg.artfctdef.muscle.artifact = artifact_muscle;
    cfg = ft_rejectartifact(cfg)
    
    cfg.padding      = 2;
    cfg.hpfilter='yes';
    cfg.hpfreq=0.5;
    cfg.hpfilttype='firws';
    cfg.hpfiltwintype= 'kaiser';
    cfg.hpfiltord =5016;
    cfg.hpfiltdev =0.0001;
    %cfg.plotfiltresp  = 'yes';
    cfg.dftfilter     ='yes';
    cfg.dftfreq       =[50 60 100 120];
    data = ft_preprocessing(cfg);
    
  
% Charger noms et coordonnées electrodes  & cr�er layout  
    fileID = fopen([cfgpr.fold '/coordAmd256.xyz']);
    Channel = textscan(fileID,'%f %f32 %f32 %f32 %s');
    fclose(fileID);
    data.label=Channel{5};
    data.elec.label=data.label';
    data.elec.pnt = double([Channel{2}, Channel{3}, Channel{4}]);
    cfg=[];
    layout = ft_prepare_layout(cfg, data);
        cfg = [];
        cfg.method   = 'summary';% 'channel' 'trial'
        cfg.layout   = layout;   % this allows for plotting individual trials
        cfg.channel  = 'all';    % do not show EOG channels
        data   = ft_rejectvisual(cfg, data);  
    % Analyse ICA
    cfg = [];
    cfg.channel = 'all';
    %cfg.method = 'runica'; 
    %cfg.runica.pca = length(data.label);
    %cfg.numcomponent = length(data.label);
    cfg.method ='fastica';
    cfg.fastica.lastEig = 50;
    cfg.fastica.numOfIC = 50;
    cfg.fastica.g = 'pow3';
    comp = ft_componentanalysis(cfg,data);
 
    cfgtopoICA = [];
    cfgtopoICA.component = [1:20];       % specify the component(s) that should be plotted
    cfgtopoICA.layout    = layout; % specify the layout file that should be used for plotting
    cfgtopoICA.comment   = 'no';
    cfgtopoICA.segm   = cfgpr.segm;

    cfgbrowsICA = [];
    cfgbrowsICA.layout = layout; % specify the layout file that should be used for plotting
    cfgbrowsICA.viewmode = 'component';
    [dataclean] = sokoft_plot_components(comp,data,cfgtopoICA,cfgbrowsICA)
            cfg = [];
        cfg.method   = 'summary';% 'channel' 'trial'
        %cfg.layout   = layout;   % this allows for plotting individual trials
        cfg.channel  = 'all';    % do not show EOG channels
        dataclean   = ft_rejectvisual(cfg, dataclean);  
    outfile=[fold_s 'dataclean.mat'];
    save(outfile, 'dataclean');
end
