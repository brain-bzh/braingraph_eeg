function [trl, event] = ft_trialfun_braingraph_new(cfg);

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);
% determine the number of samples before and after the trigger
pretrig  = -round(cfg.trialdef.prestim  * hdr.Fs);
posttrig =  round(cfg.trialdef.poststim * hdr.Fs);
% search for trigger sample
stimulus_sample = [event.sample]';

% read xlsfile containing event info
filename=[cfg.paramfold 'STIM2.xlsx'];
num = xlsread(filename,cfg.tache);

% define the trials
trl(:,1) = stimulus_sample-2400 + pretrig;  % start of segment
trl(:,2) = stimulus_sample-2400 + posttrig; % end of segment
trl(:,3) = pretrig;                    % how many samples prestimulus
% add the other information
% these columns will be represented after ft_preprocessing in "data.trialinfo"
s=size(num);
for i=1:(s(2));
trl(:,i+3) = num(:,i);
end
% Read & Reject Error Trials (from xls file) 
[badtrials,namesuj,raw]=xlsread([cfg.paramfold 'badtrials_' cfg.tache '.xlsx']);
badtrials=badtrials(find(strcmp(cfg.suj,namesuj)==1),:)';
badtrials(isnan(badtrials))=[];
trl(badtrials,:)=[];    