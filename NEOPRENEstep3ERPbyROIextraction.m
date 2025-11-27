%% NEOPRENE step 3 : individual ERP Extraction by ROI and by condition
% Run from folder containing Epochs.mat files (processed-epoched data, output from the NEOPRENEstep2processing.m script)
% This script uses epochs from script 2, averages electrodes in four ROIs, and rejects
% artefacted epochs for further analysis by scripts 4 and 6,
% also saves all individual average ERPs in a _avgERPs.mat file, for all ROIs and conditions.

close all
clear all
clc

%% SETTINGS

load proc-settings.mat % contains the following:

% peakmethod=2; % 1= latency at the maximum mismatch value 2= latency at the peak value in tested condition (better)
% samplingrate=250; % Hz (after resampling in step 1)
% baseline=... in seconds, based on choice made in step 2
% varthreshold = 60; % variance threshold for epoch*trial segment rejection
% ampthreshold = 40; % amplitude in µV threshold for epoch*trial segment rejection
% propKepttrials = 0.6; % proportion of kept trials by condition and ROI to calculate individual average
% avgthreshold=...; % if any abs value in the individual avg ERP is above, avg ERP is discarded

%% Segmentation (aka epoching)

allEpochsFile_list=dir('*Epochs.mat'); % list epoched data files in the folder
file_list = allEpochsFile_list(cellfun(@(x) isempty(regexp(x, ' \d+Epochs\.mat$', 'once')), {allEpochsFile_list.name}));

num_files=length(file_list);
for diri=1:num_files

    datafilename = file_list(diri).name; fprintf('Processing %s\n', datafilename);
    load(datafilename);

    % remove remaining bad epoch*trial segments
    for triali = 1:size(epoch_data,3)
        for channi = 1:size(epoch_data,1)
            if var(epoch_data(channi,:,triali)) > varthreshold || max(epoch_data(channi,:,triali)) > ampthreshold...
                    || min(epoch_data(channi,:,triali)) < -ampthreshold
                epoch_data(channi,:,triali) = NaN; % remove values
            end
        end
    end

    %% average electrodes by ROI

    LeftS1ROI={'FC3','FC5','C3','C5','E35','E39','E40','FT7'}; LeftS1data=[];
    RightS1ROI={'FC4','FC6','C4','C6','E110','E109','115','FT8'}; RightS1data=[];
    LeftFrontalROI={'AF3','F1','F3','F5','E18','E20','AF7','FP1'}; LeftFrontaldata=[];
    RightFrontalROI={'AF4','F2','F4','F6','E10','E118','AF8','FP2'}; RightFrontaldata=[];

    for i=1:length(channels)
        for j=1:length(LeftS1ROI)
            if isequal(channels(i),LeftS1ROI(j))
                LeftS1data=[LeftS1data;epoch_data(i,:,:)];
            end
        end
        for k=1:length(RightS1ROI)
            if isequal(channels(i),RightS1ROI(k))
                RightS1data=[RightS1data;epoch_data(i,:,:)];
            end
        end
        for l=1:length(LeftFrontalROI)
            if isequal(channels(i),LeftFrontalROI(l))
                LeftFrontaldata=[LeftFrontaldata;epoch_data(i,:,:)];
            end
        end
        for m=1:length(RightFrontalROI)
            if isequal(channels(i),RightFrontalROI(m))
                RightFrontaldata=[RightFrontaldata;epoch_data(i,:,:)];
            end
        end
    end

    % average electrodes by  Ipsilateral vs. Contralateral ROI
    if contains(datafilename,'_L_') % for subjects stimulated on the Left arm
        IpsiS1ERP=squeeze(nanmean(LeftS1data,1)); ContraS1ERP=squeeze(nanmean(RightS1data,1));
        IpsiFrontalERP=squeeze(nanmean(LeftFrontaldata,1)); ContraFrontalERP=squeeze(nanmean(RightFrontaldata,1));
    elseif contains(datafilename,'_R_') % for subjects stimualted on the right arm
        ContraS1ERP=squeeze(nanmean(LeftS1data,1)); IpsiS1ERP=squeeze(nanmean(RightS1data,1));
        ContraFrontalERP=squeeze(nanmean(LeftFrontaldata,1)); IpsiFrontalERP=squeeze(nanmean(RightFrontaldata,1));
    end

    % Calculate proportion of kept trials by ROI and reject data failing
    % the threshold for trial averaging

    PropKeptContraS1ERP=(sum(~isnan(ContraS1ERP(1,:))))/size(ContraS1ERP,2);
    if PropKeptContraS1ERP < propKepttrials, ContraS1ERP(:,:) = NaN; end

    PropKeptIpsiS1ERP=(sum(~isnan(IpsiS1ERP(1,:))))/size(IpsiS1ERP,2);
    if PropKeptIpsiS1ERP < propKepttrials, IpsiS1ERP(:,:) = NaN; end

    PropKeptContraFrontalERP=(sum(~isnan(ContraFrontalERP(1,:))))/size(ContraFrontalERP,2);
    if PropKeptContraFrontalERP < propKepttrials, ContraFrontalERP(:,:) = NaN; end

    PropKeptIpsiFrontalERP=(sum(~isnan(IpsiFrontalERP(1,:))))/size(IpsiFrontalERP,2);
    if PropKeptIpsiFrontalERP < propKepttrials, IpsiFrontalERP(:,:) = NaN; end

    % Average trials to calculate ERPs
    avgIpsiS1ERP=nanmean(IpsiS1ERP,2); avgContraS1ERP=nanmean(ContraS1ERP,2);
    avgIpsiFrontalERP=nanmean(IpsiFrontalERP,2); avgContraFrontalERP=nanmean(ContraFrontalERP,2);

    % Reject individual average ERPs when any value is above threshold
    if abs(any(avgContraFrontalERP))>avgthreshold, avgContraFrontalERP(:)=NaN; end 
    if abs(any(avgContraS1ERP))>avgthreshold, avgContraS1ERP(:)=NaN; end 
    if abs(any(avgIpsiFrontalERP))>avgthreshold, avgIpsiFrontalERP(:)=NaN; end 
    if abs(any(avgIpsiS1ERP))>avgthreshold, avgIpsiS1ERP(:)=NaN; end

    %% save ERPs by condition

    rootname=extractBefore(datafilename,'Epochs.mat');
    avgERPfilename=[rootname '_avgERPs.mat'];
    alltrialsERPfilename=[rootname '_alltrialsERPs.mat'];

    % average ERPs
    save(avgERPfilename,'avgIpsiS1ERP','avgContraS1ERP','avgIpsiFrontalERP','avgContraFrontalERP');

    % all trials
    save(alltrialsERPfilename,'IpsiS1ERP','ContraS1ERP','IpsiFrontalERP','ContraFrontalERP');

end
