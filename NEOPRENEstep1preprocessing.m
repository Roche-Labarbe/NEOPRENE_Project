%% NEOPRENE Step 1 : Preprocessing using EEGLAB toolbox

% Run from folder containing raw .mff files from EGI Geodesic's Net Station acquisition

clear all
close all
clc

%% SETTINGS
ICAtype = 1; % 1=Runica (default), 2=Picard (faster, but does not converge for all datasets)

%% load eeglab toolbox

restoredefaultpath
eeglab_dir = dir('eeglab*'); % Look for eeglab folder
if ~isempty(eeglab_dir)
    addpath(eeglab_dir(1).name); % Add the first match found
    eeglab; % Start EEGLAB
else, error('EEGLAB folder not found. Please ensure it is in the working directory.');
end

%% Import EEG data

file_list=dir('*.mff'); % list EGI raw data files in the folder
num_files=length(file_list);
for diri=1:num_files

    datafilename = file_list(diri).name;
    subject=extractBefore(datafilename,'.mff'); fprintf('Analyzing %s\n', subject);

    % import data file
    EEG = pop_mffimport({datafilename},{'mffkey_cel'},0,0);
    EEG = pop_editset(EEG, 'subject', subject);

    %% Clean event info

    previouslatency=0; % using latency relative to start of the recording
    for i = 1:length(EEG.event)
        if strcmp(EEG.event(i).code, 'star')
            eventType = str2double(EEG.event(i).type);
            latencyDiff=EEG.event(i).latency-previouslatency;
            if latencyDiff<=3650, suffix = '34'; % onset to onset = 3.65s and stim lasts 0.2 so ISI = 3.45s
            elseif latencyDiff>3650 && latencyDiff<=3750, suffix = '35';
            elseif latencyDiff>3750 && latencyDiff<=3850, suffix = '36';
            elseif latencyDiff>3850, suffix = '37';
            end
            if eventType == 1
                EEG.event(i).type='Familiarization 34'; % the first trial has no ISI so we put it in the shortest ISI group
                previouslatency=EEG.event(i).latency; % setting reference for the next marker
            elseif eventType >= 2 && eventType <= 40
                EEG.event(i).type=['Familiarization ' suffix]; previouslatency=EEG.event(i).latency;
            elseif eventType==51
                EEG.event(i).type=['Other standard ' suffix]; previouslatency=EEG.event(i).latency;
            elseif eventType==53
                EEG.event(i).type=['Deviant ' suffix]; previouslatency=EEG.event(i).latency;
            elseif eventType==54
                EEG.event(i).type=['Standard matched to deviant ' suffix]; previouslatency=EEG.event(i).latency;
            elseif eventType==55
                EEG.event(i).type=['Omission ' suffix]; previouslatency=EEG.event(i).latency;
            elseif eventType==57
                EEG.event(i).type=['Postomission ' suffix]; previouslatency=EEG.event(i).latency;
            elseif eventType >= 150 && eventType <= 190
                EEG.event(i).type=['Control ' suffix]; previouslatency=EEG.event(i).latency;
            end
        end
    end

    % remove unused events
    event_codes_to_remove = {'CELL', 'bgin','stop','SESS','TRSP'};
    event_types_to_remove = {'boundary'};
    event_indices_to_remove = find(ismember({EEG.event.code}, event_codes_to_remove)|ismember({EEG.event.type}, event_types_to_remove));
    EEG.event(event_indices_to_remove) = [];

    %% Prepare channels

    % rename channels with 10-20 names when they exist
    EEG = pop_chanedit(EEG, 'changefield', {2 'labels' 'AF8'}); EEG = pop_chanedit(EEG, 'changefield', {3 'labels' 'AF4'});
    EEG = pop_chanedit(EEG, 'changefield', {4 'labels' 'F2'}); EEG = pop_chanedit(EEG, 'changefield', {6 'labels' 'FCz'});
    EEG = pop_chanedit(EEG, 'changefield', {9 'labels' 'FP2'}); EEG = pop_chanedit(EEG, 'changefield', {11 'labels' 'Fz'});
    EEG = pop_chanedit(EEG, 'changefield', {13 'labels' 'FC1'}); EEG = pop_chanedit(EEG, 'changefield', {15 'labels' 'FPz'});
    EEG = pop_chanedit(EEG, 'changefield', {16 'labels' 'AFz'}); EEG = pop_chanedit(EEG, 'changefield', {19 'labels' 'F1'});
    EEG = pop_chanedit(EEG, 'changefield', {22 'labels' 'FP1'}); EEG = pop_chanedit(EEG, 'changefield', {23 'labels' 'AF3'});
    EEG = pop_chanedit(EEG, 'changefield', {24 'labels' 'F3'}); EEG = pop_chanedit(EEG, 'changefield', {26 'labels' 'AF7'});
    EEG = pop_chanedit(EEG, 'changefield', {27 'labels' 'F5'}); EEG = pop_chanedit(EEG, 'changefield', {28 'labels' 'FC5'});
    EEG = pop_chanedit(EEG, 'changefield', {29 'labels' 'FC3'}); EEG = pop_chanedit(EEG, 'changefield', {30 'labels' 'C1'});
    EEG = pop_chanedit(EEG, 'changefield', {33 'labels' 'F7'}); EEG = pop_chanedit(EEG, 'changefield', {34 'labels' 'FT7'});
    EEG = pop_chanedit(EEG, 'changefield', {36 'labels' 'C3'}); EEG = pop_chanedit(EEG, 'changefield', {37 'labels' 'CP1'});
    EEG = pop_chanedit(EEG, 'changefield', {41 'labels' 'C5'}); EEG = pop_chanedit(EEG, 'changefield', {42 'labels' 'CP3'});
    EEG = pop_chanedit(EEG, 'changefield', {45 'labels' 'T3'}); EEG = pop_chanedit(EEG, 'changefield', {46 'labels' 'TP7'});
    EEG = pop_chanedit(EEG, 'changefield', {47 'labels' 'CP5'}); EEG = pop_chanedit(EEG, 'changefield', {51 'labels' 'P5'});
    EEG = pop_chanedit(EEG, 'changefield', {52 'labels' 'P3'}); EEG = pop_chanedit(EEG, 'changefield', {55 'labels' 'CPz'});
    EEG = pop_chanedit(EEG, 'changefield', {57 'labels' 'TP9'}); EEG = pop_chanedit(EEG, 'changefield', {58 'labels' 'P7'});
    EEG = pop_chanedit(EEG, 'changefield', {60 'labels' 'P1'}); EEG = pop_chanedit(EEG, 'changefield', {62 'labels' 'Pz'});
    EEG = pop_chanedit(EEG, 'changefield', {64 'labels' 'P9'}); EEG = pop_chanedit(EEG, 'changefield', {65 'labels' 'PO7'});
    EEG = pop_chanedit(EEG, 'changefield', {67 'labels' 'PO3'}); EEG = pop_chanedit(EEG, 'changefield', {70 'labels' 'O1'});
    EEG = pop_chanedit(EEG, 'changefield', {72 'labels' 'POz'}); EEG = pop_chanedit(EEG, 'changefield', {75 'labels' 'Oz'});
    EEG = pop_chanedit(EEG, 'changefield', {77 'labels' 'PO4'}); EEG = pop_chanedit(EEG, 'changefield', {83 'labels' 'O2'});
    EEG = pop_chanedit(EEG, 'changefield', {85 'labels' 'P2'}); EEG = pop_chanedit(EEG, 'changefield', {87 'labels' 'CP2'});
    EEG = pop_chanedit(EEG, 'changefield', {90 'labels' 'PO8'}); EEG = pop_chanedit(EEG, 'changefield', {92 'labels' 'P4'});
    EEG = pop_chanedit(EEG, 'changefield', {93 'labels' 'CP4'}); EEG = pop_chanedit(EEG, 'changefield', {95 'labels' 'P10'});
    EEG = pop_chanedit(EEG, 'changefield', {96 'labels' 'P8'}); EEG = pop_chanedit(EEG, 'changefield', {97 'labels' 'P6'});
    EEG = pop_chanedit(EEG, 'changefield', {98 'labels' 'CP6'}); EEG = pop_chanedit(EEG, 'changefield', {100 'labels' 'TP10'});
    EEG = pop_chanedit(EEG, 'changefield', {102 'labels' 'TP8'}); EEG = pop_chanedit(EEG, 'changefield', {103 'labels' 'C6'});
    EEG = pop_chanedit(EEG, 'changefield', {104 'labels' 'C4'}); EEG = pop_chanedit(EEG, 'changefield', {105 'labels' 'C2'});
    EEG = pop_chanedit(EEG, 'changefield', {108 'labels' 'T4'}); EEG = pop_chanedit(EEG, 'changefield', {111 'labels' 'FC4'});
    EEG = pop_chanedit(EEG, 'changefield', {112 'labels' 'FC2'}); EEG = pop_chanedit(EEG, 'changefield', {116 'labels' 'FT8'});
    EEG = pop_chanedit(EEG, 'changefield', {117 'labels' 'FC6'}); EEG = pop_chanedit(EEG, 'changefield', {122 'labels' 'F8'});
    EEG = pop_chanedit(EEG, 'changefield', {123 'labels' 'F6'}); EEG = pop_chanedit(EEG, 'changefield', {124 'labels' 'F4'});

    % remove non-brain channels (jaw, neck)
    EEG = pop_select( EEG, 'rmchannel',{'E1','E8','E14','E17','E21','E25','E32','E38','E43','E44','E48','E49',...
        'E56','E63','E68','E69','E73','E74','E81','E82','E88','E89','E94','E99','E107','E113','E114','E119',...
        'E120','E121','E125','E126','E127','E128','E129'});

    %% resample data
    EEG = pop_resample(EEG, 250); % 1000 to 250 Hz

    %% filtering
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.5,'hicutoff',20); % bandpass
    EEG = pop_eegfiltnew(EEG, 'locutoff', 49, 'hicutoff', 51, 'revfilt', 1); % line noise notch

    %% Automatic bad channel detection with ASR data correction
    EEG = pop_clean_rawdata(EEG,'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off',...
        'BurstCriterion',20,'WindowCriterion','off','BurstRejection','off','Distance','Euclidian','WindowCriterionTolerances','off');

    %% ICA
    % decomposition
    if ICAtype == 1
        EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'rndreset','yes','interrupt','off');
    elseif ICAtype == 2
        EEG = pop_runica(EEG,'icatype','picard','maxiter',500,'mode','standard');
    end
    % labeling and flagging
    EEG = pop_iclabel(EEG,'default');
    EEG = pop_icflag(EEG,[NaN NaN;0.9 1;0.9 1;NaN NaN;0.9 1;0.9 1;NaN NaN]);

    % remove flagged components
    EEG = pop_subcomp(EEG, [], 0);

    %% rereference to common average
    EEG = pop_reref( EEG, []);

    %% determine side stimulated from file name and filling in the "group" in the .set file
    if contains(datafilename,'_R.mff'), EEG.group='Right Stim';
    elseif contains(datafilename,'_L.mff'), EEG.group='Left Stim';
    end

    %% save preprocessed data in EEGlab format
    nameSet = [subject '_preprocessed.set'];
    EEG = pop_saveset(EEG,'filename', nameSet); % save preprocessed dataset for future work on time series

    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0); % keep dataset loaded for further exploration in GUI

end

eeglab redraw;