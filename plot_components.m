

function [dataclean] = plot_components(comp,data,cfgtopoICA,cfgbrowsICA)

% plot the components for visual inspection
close all

cfgerp = [];
cfgerp.vartrllength = 2;
%%% Do an average of the components and plot the result
avg_comp = ft_timelockanalysis(cfgerp,comp);
ntrials = length(comp.trial);
%%% create random partitions of the trials to have partial averages

cfgerp.trials = randi(ntrials,[1 floor(0.25*ntrials)]);
avg_comp2 = ft_timelockanalysis(cfgerp,comp);

cfgerp.trials = randi(ntrials,[1 floor(0.50*ntrials)]);
avg_comp3 = ft_timelockanalysis(cfgerp,comp);

cfgerp.trials = randi(ntrials,[1 floor(0.75*ntrials)]);
avg_comp4 = ft_timelockanalysis(cfgerp,comp);

% figure
% for i=1:32
%     subplot(8,4,i)
%     plot(avg_comp.time,avg_comp.avg(i,:));
%     set(gca,'YDir','reverse');
%     title(avg_comp.label{i});
% end;
% 
% figure
% for i=33:length(comp.label)
%     subplot(8,4,i-32)
%     plot(avg_comp.time,avg_comp.avg(i,:));
%     set(gca,'YDir','reverse');
%     title(avg_comp.label{i});
% end;

% figure
% for i=1:32
%     subplot(8,4,i)
%     
%     for j=1:size(comp.trial,2)        
%     tempimage(j,:)=comp.trial{j}(i,:);  
%     end; 
%  
%     imagesc(comp.time{1},1:size(comp.trial,2),tempimage);
%     title(avg_comp.label{i});
% end;
% 
% figure
% for i=33:length(comp.label)
%     subplot(8,4,i-32)
%     
%     for j=1:size(comp.trial,2)        
%     tempimage(j,:)=comp.trial{j}(i,:);  
%     end; 
%  
%     imagesc(comp.time{1},1:size(comp.trial,2),tempimage);
%     title(avg_comp.label{i});
% end;

cfgTF = []; 
cfgTF.method = 'mtmfft'; 
cfgTF.output = 'pow'; 
cfgTF.tapsmofrq = 1;
cfgTF.foi = 0.5:0.2:50;
cfgTF.pad = 2.5;
%freqcomp = ft_freqanalysis(cfgTF,avg_comp);
freqcomp = ft_freqanalysis(cfgTF,comp);

cfgitc = [];
cfgitc.method = 'wavelet';
cfgitc.foi = 5:1:50;
cfgitc.toi    = (cfgtopoICA.segm(1)):0.01:cfgtopoICA.segm(2);
cfgitc.pad = 2.5;
cfgitc.output = 'fourier';
freqitc = ft_freqanalysis(cfgitc, comp);

itc = [];
itc.label     = freqitc.label;
itc.freq      = freqitc.freq;
itc.time      = freqitc.time;
itc.dimord    = 'chan_freq_time';

F = freqitc.fourierspctrm;   % copy the Fourier spectrum
N = size(F,1);           % number of trials
% compute inter-trial linear coherence (itlc)
itc.itlc      = sum(F) ./ (sqrt(N*sum(abs(F).^2)));
itc.itlc      = abs(itc.itlc);     % take the absolute value, i.e. ignore phase
itc.itlc      = squeeze(itc.itlc); % remove the first singleton dimension



%cfgtest.linewidth = 2; 
% 
% figure
% for i=1:32
%     subplot(8,4,i)
%     cfgtest.channel = freqcomp.label{i};
%     semilogy(freqcomp.freq,freqcomp.powspctrm(i,:),'Linewidth',2);
%  %   ft_singleplotER(cfgtest,freqcomp);
%     title(freqcomp.label{i});
% end;
% 
% figure
% for i=33:length(comp.label)
%     subplot(8,4,i-32)
%     cfgtest.channel = freqcomp.label{i};
%     semilogy(freqcomp.freq,freqcomp.powspctrm(i,:),'Linewidth',2);
%     %ft_singleplotER(cfgtest,freqcomp);
%     title(freqcomp.label{i});
% end;



ft_databrowser(cfgbrowsICA, comp);

if length(comp.label) >32

cfgtopoICA.component = 1:32;

figure
ft_topoplotIC(cfgtopoICA, comp);

cfgtopoICA.component = 33:length(comp.label);

figure
ft_topoplotIC(cfgtopoICA, comp);

else
    cfgtopoICA.component = 1:length(comp.label);
    figure
ft_topoplotIC(cfgtopoICA, comp);

end;

    


enduser = 0; 

while enduser==0
    
userchoice = input('Enter C to plot a specific component or R to reject components','s'); 

if strcmp(userchoice,'C')
    
    compnum2 = input('Enter component numbers e.g. [1 2 3 4]','s');
    
    eval(['complist = ' compnum2 ';']); 
    
    for k = 1:length(complist)
        compnum = complist(k);
    
    figcomps(compnum)=figure('Name',['Component ' num2str(compnum) ]); 
    
    
    subplot(5,1,1)
    semilogy(freqcomp.freq,freqcomp.powspctrm(compnum,:),'Linewidth',2);
    title('Spectrum'); 
    
    subplot(5,1,2)
    
    for j=1:size(comp.trial,2)        
    tempimage(j,:)=comp.trial{j}(compnum,:);  
    end; 
 
    imagesc(comp.time{1},1:size(comp.trial,2),tempimage);
   % colorbar
    
    title('All trials'); 
    
    subplot(5,1,3)
 hold on   
 plot(avg_comp.time,avg_comp.avg(compnum,:),'LineWidth',2);
 
    plot(avg_comp.time,avg_comp.avg(compnum,:),...
        avg_comp.time,avg_comp2.avg(compnum,:),...
        avg_comp.time,avg_comp3.avg(compnum,:),...
        avg_comp.time,avg_comp4.avg(compnum,:));
    set(gca,'YDir','reverse');
    hold off;
    
    title('ERP of component');
    
    subplot(5, 1, 4);
    imagesc(itc.time, itc.freq, squeeze(itc.itlc(1,:,:))); 
    axis xy
    title('inter-trial linear coherence');
    
    subplot(5,1,5)
    cfgtopoICA.component =compnum;
    cfgtopoICA.colorbar = 'East'; 
    
    ft_topoplotIC(cfgtopoICA, comp);
    
    set(figcomps(compnum),'Name',['Component ' num2str(compnum) ]);
    
    end;
    
elseif strcmp(userchoice,'R')
    aa = input('List of components to reject ? ', 's');
    cfgrej = [];
    cfgrej.demean = 'no';

    eval(['cfgrej.component = ' aa ]);
    dataclean = ft_rejectcomponent(cfgrej,comp,data);
        cfg=[];
        %cfg.layout = cfgbrowsICA.layout;
        cfg.method   = 'trial';
        cfg.channel  = 'all';    % do not show EOG channels
        dataclean   = ft_rejectvisual(cfg, dataclean);  
    verif = input('Is ICA analysis complete (Type "yes" or "no")');
    if strcmp(verif,'yes')
    enduser = 1;
    elseif strcmp(verif,'no')
        enduser =0;
    else 
        disp('wrong entry');
        pause(0.5);
    end
else
    
    disp('wrong entry');
    pause(0.5);
end

end


