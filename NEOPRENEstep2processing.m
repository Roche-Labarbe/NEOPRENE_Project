%% NEOPRENE Step 2 Processing : Epoching and baseline correction
% Run from folder containing .set files (preprocessed data, output from the NEOPRENEstep1preprocessing.m script)

clear all
close all
clc

%% SETTINGS

load('proc-settings.mat')

%% load eeglab toolbox

restoredefaultpath
eeglab_dir = dir('eeglab*'); % Look for any folder starting with "eeglab"
if ~isempty(eeglab_dir)
    addpath(eeglab_dir(1).name); % Add the first match found
    eeglab; % Start EEGLAB
else, error('EEGLAB folder not found. Please ensure it is in the working directory.');
end

%% Import preprocessed EEG data (from script 1) into a eeglab

file_list=dir('*preprocessed.set');
num_files=length(file_list);

%% epoching / segmentation

conditions={'Familiarization 34','Familiarization 35','Familiarization 36','Familiarization 37',...
    'Other standard 34','Other standard 35','Other standard 36','Other standard 37',...
    'Deviant 34','Deviant 35','Deviant 36','Deviant 37',...
    'Standard matched to deviant 34','Standard matched to deviant 35','Standard matched to deviant 36','Standard matched to deviant 37',...
    'Omission 35','Postomission 35','Control 34','Control 35','Control 36','Control 37'};

for k=1:length(conditions) % loop with preprocessed .set reload, because eeglab segments 1 event type at a time

    for diri=1:num_files

        datafilename = file_list(diri).name;
        subject=extractBefore(datafilename,'_preprocessed.set');

        if (contains(subject,'sub-20DD_R') && contains(conditions{k},'Control'))...
                || (contains(subject,'sub-17CE_R') && contains(conditions{k},'Control'))
            continue; end % there are no control trials for sub-17CE and sub-20DD at 0 YO because of device bug during acquisition

        EEG = pop_loadset('filename',datafilename);

        EEG.condition=conditions{k}; % fills condition in .set file

        if ~any(strcmp({EEG.event.type}, conditions{k})) % check if that condition exists in the file
            continue; end

        % actual segmentation
        nameEpochs = [subject '_' conditions{k} 'Epochs.set'];
        EEG = pop_epoch(EEG,conditions{k},[-baseline postonset],'newname',nameEpochs,'epochinfo', 'yes');

        % Fix xmin/xmax in EEG structure if there is a single epoch because EEGlab treats it as continuous data and sets xmin to 0 instead of
        % using baseline provided for multiple epochs
        if EEG.trials == 1 && EEG.xmin == 0
            EEG.xmin = -baseline; EEG.xmax = postonset; EEG.times = linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts);
        end

        % % baseline depending on ISI jitter, to account for pre-onset changes due to prediction processes in trials with long ISI
        if contains(conditions{k},' 34')
            EEG = pop_rmbase(EEG,[-200 -100],[]); % baseline correction (window is in ms relative to onset)
        elseif contains(conditions{k},' 35')
            EEG = pop_rmbase(EEG,[-300 -200],[]);
        elseif contains(conditions{k},' 36')
            EEG = pop_rmbase(EEG,[-400 -300],[]);
        elseif contains(conditions{k},' 37')
            EEG = pop_rmbase(EEG,[-500 -400],[]);
        end

        %% save epochs for Matlab
        nameEpochsMat = [subject '_' conditions{k} 'Epochs.mat'];
        epoch_data = EEG.data;
        timepoints = EEG.times;
        channels = {EEG.chanlocs.labels}';
        save(nameEpochsMat,'epoch_data','timepoints','channels');

    end
end

clear all

%% Regroup epochs with different ISI in single files for Analysis by event type

file_list=dir('*Epochs.mat');
num_files=length(file_list);

% Use containers.Map to group files by prefix in the file name
fileGroups = containers.Map;

for diri = 1:num_files
    datafilename = file_list(diri).name;

    % extract prefix
    tokens = regexp(datafilename, '^(.*?)(?: \d+Epochs)\.mat$', 'tokens');
    if ~isempty(tokens)
        prefix = tokens{1}{1};

        if isKey(fileGroups, prefix)
            tmp = fileGroups(prefix);
            tmp{end+1} = datafilename;
            fileGroups(prefix) = tmp;
        else
            fileGroups(prefix) = {datafilename};
        end
    end
end

% charge and concatente segments from the different ISI groups, for each prefix group
groupKeys = keys(fileGroups);
for i = 1:length(groupKeys)
    prefix = groupKeys{i};
    groupList = fileGroups(prefix);

    epoch_data = []; timepoints = []; channels = {};

    for j = 1:length(groupList)
        fname = groupList{j}; fileData = load(fname);

        if isempty(epoch_data) % first data to concatenate
            epoch_data = fileData.epoch_data;
            timepoints = fileData.timepoints;
            channels = fileData.channels;
        else
            epoch_data = cat(3, epoch_data, fileData.epoch_data); % adds subsequent data
        end
    end

    save([prefix 'Epochs.mat'],'epoch_data','timepoints','channels');
    fprintf('Saved %sEpochs.mat\n', prefix);

end
