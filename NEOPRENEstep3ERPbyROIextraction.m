%% NEOPRENE step 3 : individual ERP Extraction by ROI and by condition
% Run from folder containing Epochs.mat files (processed-epoched data, output from the NEOPRENEstep2processing.m script)
% This script uses epochs from script 2, averages electrodes in four ROIs, and rejects
% artefacted epochs for further analysis by scripts 4 and 6,
% also saves all individual average ERPs in a _avgERPs.mat file, for all ROIs and conditions.

close all
clear all
clc

%% SETTINGS

load proc-settings.mat % contains parameters that can be adjusted

%% load eeglab toolbox

restoredefaultpath
eeglab_dir = dir('eeglab*'); % Look for any folder starting with "eeglab"
if ~isempty(eeglab_dir)
    addpath(eeglab_dir(1).name); % Add the first match found
    eeglab; % Start EEGLAB
else, error('EEGLAB folder not found. Please ensure it is in the working directory.');
end

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

    % define ROIs

    if ~contains(datafilename,'2Y_') % ROIs at 0yo
        LeftS1ROI={'FC3','FC5','C3','C5','E35','E39','E40','FT7'};
        RightS1ROI={'FC4','FC6','C4','C6','E110','E109','E115','FT8'};
        LeftFrontalROI={'AF3','F1','F3','F5','E18','E20','AF7','FP1'};
        RightFrontalROI={'AF4','F2','F4','F6','E10','E118','AF8','FP2'};
    elseif contains(datafilename,'2Y_') % ROIs at 2yo
        LeftS1ROI={'FC3','C1','E35','C3','C5','CP3','CP1'};
        RightS1ROI={'FC4','C2','E110','C4','C6','CP4','CP2'};
        LeftFrontalROI={'AF3','E18','F1','F3','E12','E20','FC1'};
        RightFrontalROI={'AF4','E10','F2','F4','E5','E118','FC2'};
    end

    % Preallocate logical indices for each ROI
    isLeftS1 = ismember(channels, LeftS1ROI);
    isRightS1 = ismember(channels, RightS1ROI);
    isLeftFrontal = ismember(channels, LeftFrontalROI);
    isRightFrontal = ismember(channels, RightFrontalROI);

    % Extract corresponding data
    LeftS1data = epoch_data(isLeftS1,:,:);
    RightS1data = epoch_data(isRightS1,:,:);
    LeftFrontaldata = epoch_data(isLeftFrontal,:,:);
    RightFrontaldata = epoch_data(isRightFrontal,:,:);

    % average electrodes by  Ipsilateral vs. Contralateral ROI
    if contains(datafilename,'_L_') % for subjects stimulated on the Left arm
        IpsiS1ERP=squeeze(nanmean(LeftS1data,1)); ContraS1ERP=squeeze(nanmean(RightS1data,1));
        IpsiFrontalERP=squeeze(nanmean(LeftFrontaldata,1)); ContraFrontalERP=squeeze(nanmean(RightFrontaldata,1));
    elseif contains(datafilename,'_R_') % for subjects stimualted on the right arm
        ContraS1ERP=squeeze(nanmean(LeftS1data,1)); IpsiS1ERP=squeeze(nanmean(RightS1data,1));
        ContraFrontalERP=squeeze(nanmean(LeftFrontaldata,1)); IpsiFrontalERP=squeeze(nanmean(RightFrontaldata,1));
    end

    %% Calculate proportion of kept trials by ROI and reject data failing the threshold for trial averaging

    % Define cell array for ERP data
    ERPData = {ContraS1ERP, IpsiS1ERP, ContraFrontalERP, IpsiFrontalERP};
    ERPNames = {'ContraS1ERP', 'IpsiS1ERP', 'ContraFrontalERP', 'IpsiFrontalERP'};

    % Loop through each ERP dataset
    for i = 1:length(ERPData)
        PropKept = sum(~isnan(ERPData{i}(1,:))) / size(ERPData{i}, 2);
        if PropKept < propKepttrials
            ERPData{i}(:,:) = NaN;
        end
    end

    % Calculate average ERPs
    avgERPs = cellfun(@(x) nanmean(x, 2), ERPData, 'UniformOutput', false);

    % Reject individual average ERPs when any value is above threshold
    for i = 1:length(avgERPs)
        if any(abs(avgERPs{i}) > avgthreshold)
            avgERPs{i}(:) = NaN;
        end
    end

    % Assign averaged ERPs to variables
    avgContraS1ERP = avgERPs{1}; avgIpsiS1ERP = avgERPs{2}; avgContraFrontalERP = avgERPs{3}; avgIpsiFrontalERP = avgERPs{4};


    %% save ERPs by condition

    rootname=extractBefore(datafilename,'Epochs.mat');
    avgERPfilename=[rootname '_avgERPs.mat'];
    alltrialsERPfilename=[rootname '_alltrialsERPs.mat'];

    % average ERPs
    save(avgERPfilename,'avgIpsiS1ERP','avgContraS1ERP','avgIpsiFrontalERP','avgContraFrontalERP');

    % all trials
    save(alltrialsERPfilename,'IpsiS1ERP','ContraS1ERP','IpsiFrontalERP','ContraFrontalERP');

end

eeglab redraw;