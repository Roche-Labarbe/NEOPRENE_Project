%% NEOPRENE step 5 : ERP Analyses
% Run from folder containing _avgERPs.mat files (output from the NEOPRENEstep3ERPextraction.m script)
% This script calculates individual mismatch traces and values at a specific peak
% from avgERPs for all conditions, and saves individual _MM.mat and _RS.mat files for
% further analysis by script 6

close all
clear all
clc

%% SETTINGS

peakstudied=2; % 1 is for P2 at ~150ms, 2 is for N3 the slow wave around 500ms

load proc-settings.mat % processing parameters

%% define peak window

if peakstudied==1
    ERPwindowstart=ERPwindowstart1; % in seconds after stim onset, when to start looking for maximum mismatch
    ERPwindowstop=ERPwindowstop1; % in seconds after stim onset, when to stop looking for maximum mismatch
elseif peakstudied==2
    ERPwindowstart=ERPwindowstart2;
    ERPwindowstop=ERPwindowstop2;
end

framestart=fix((baseline+ERPwindowstart)*samplingrate);
framestop=fix((baseline+ERPwindowstop)*samplingrate);

%% Repetition suppression : Familiar vs. Control blocks and Familiar by trial

file_list=dir('*Familiarization_avgERPs.mat');
num_files=length(file_list);

for diri=1:num_files

    % load Familiarization and Control average ERPs

    Famfilename = file_list(diri).name; fprintf('Processing %s\n', Famfilename);

    rootname = extractBefore(Famfilename,'_Familiarization_avgERPs.mat');
    AllFamtrialsfilename = [rootname '_Familiarization_alltrialsERPs.mat'];

    if contains(Famfilename,'sub-17CE')||contains(Famfilename,'sub-20DD') % sub-17 and sub-20 0Y do not have a control phase so not included in RS ; remove line for 2YO analysis
        mismatchRSContraFrontalvalue=NaN; mismatchRSContraS1value=NaN; mismatchRSIpsiFrontalvalue=NaN; mismatchRSIpsiS1value=NaN;
    else
        Controlfilename = [rootname '_Control_avgERPs.mat'];

        %% For RS between Familiarization vs Control phases
        load(Famfilename);
        avgContraFrontalERPFam=avgContraFrontalERP; avgContraS1ERPFam=avgContraS1ERP;
        avgIpsiFrontalERPFam=avgIpsiFrontalERP; avgIpsiS1ERPFam=avgIpsiS1ERP;
        clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

        load(Controlfilename);
        avgContraFrontalERPControl=avgContraFrontalERP; avgContraS1ERPControl=avgContraS1ERP;
        avgIpsiFrontalERPControl=avgIpsiFrontalERP; avgIpsiS1ERPControl=avgIpsiS1ERP;
        clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

        % calculate RS / mismatch traces
        RSContraFrontal=avgContraFrontalERPFam-avgContraFrontalERPControl;
        RSContraS1=avgContraS1ERPFam-avgContraS1ERPControl;
        RSIpsiFrontal=avgIpsiFrontalERPFam-avgIpsiFrontalERPControl;
        RSIpsiS1=avgIpsiS1ERPFam-avgIpsiS1ERPControl;

        %% Mismatch calculations using peaks

        % Frontal Contralateral
        if peakstudied==1
            [maxContraFrontalRSvalue,maxContraFrontalRSidx]=max(avgContraFrontalERPFam(framestart:framestop)); % finds most positive Fam value
        elseif peakstudied==2
            [maxContraFrontalRSvalue,maxContraFrontalRSidx]=min(avgContraFrontalERPFam(framestart:framestop)); % finds most negative Fam value
        end
        minContraFrontalERPFam=mean(avgContraFrontalERPFam(fix(framestart+maxContraFrontalRSidx-smooth):fix(framestart+maxContraFrontalRSidx+smooth)));
        minContraFrontalERPControl=mean(avgContraFrontalERPControl(fix(framestart+maxContraFrontalRSidx-smooth):fix(framestart+maxContraFrontalRSidx+smooth)));
        mismatchRSContraFrontalvalue=minContraFrontalERPFam-minContraFrontalERPControl;

        % S1 Contralateral
        if peakstudied==1
            [maxContraS1RSvalue,maxContraS1RSidx]=max(avgContraS1ERPFam(framestart:framestop));
        elseif peakstudied==2
            [maxContraS1RSvalue,maxContraS1RSidx]=min(avgContraS1ERPFam(framestart:framestop));
        end
        minContraS1ERPFam=mean(avgContraS1ERPFam(fix(framestart+maxContraS1RSidx-smooth):fix(framestart+maxContraS1RSidx+smooth)));
        minContraS1ERPControl=mean(avgContraS1ERPControl(fix(framestart+maxContraS1RSidx-smooth):fix(framestart+maxContraS1RSidx+smooth)));
        mismatchRSContraS1value=minContraS1ERPFam-minContraS1ERPControl;

        % Frontal Ipsilateral
        if peakstudied==1
            [maxIpsiFrontalRSvalue,maxIpsiFrontalRSidx]=max(avgIpsiFrontalERPFam(framestart:framestop));
        elseif peakstudied==2
            [maxIpsiFrontalRSvalue,maxIpsiFrontalRSidx]=min(avgIpsiFrontalERPFam(framestart:framestop));
        end
        minIpsiFrontalERPFam=mean(avgIpsiFrontalERPFam(fix(framestart+maxIpsiFrontalRSidx-smooth):fix(framestart+maxIpsiFrontalRSidx+smooth)));
        minIpsiFrontalERPControl=mean(avgIpsiFrontalERPControl(fix(framestart+maxIpsiFrontalRSidx-smooth):fix(framestart+maxIpsiFrontalRSidx+smooth)));
        mismatchRSIpsiFrontalvalue=minIpsiFrontalERPFam-minIpsiFrontalERPControl;

        % Somatosensory Ipsilateral
        if peakstudied==1
            [maxIpsiS1RSvalue,maxIpsiS1RSidx]=min(avgIpsiS1ERPFam(framestart:framestop));
        elseif peakstudied==2
            [maxIpsiS1RSvalue,maxIpsiS1RSidx]=min(avgIpsiS1ERPFam(framestart:framestop));
        end
        minIpsiS1ERPFam=mean(avgIpsiS1ERPFam(fix(framestart+maxIpsiS1RSidx-smooth):fix(framestart+maxIpsiS1RSidx+smooth)));
        minIpsiS1ERPControl=mean(avgIpsiS1ERPControl(fix(framestart+maxIpsiS1RSidx-smooth):fix(framestart+maxIpsiS1RSidx+smooth)));
        mismatchRSIpsiS1value=minIpsiS1ERPFam-minIpsiS1ERPControl;

    end

    %% for RS during Familiarization phase

    load(AllFamtrialsfilename); % load all Familiarization trials
    trialsPerBlock = 10; %averaging 10 trials to see suppresion across the Fam phase
    numBlocks=(size(ContraFrontalERP,2))/trialsPerBlock;

    % Frontal Contralateral
    for i=1:size(ContraFrontalERP,2)
        ContraFrontalvaluebytrial(i)=nanmean(ContraFrontalERP(framestart:framestop,i));
    end
    ContraFrontalvaluebyblock= nan(1,numBlocks);
    for blocki=1:numBlocks
        starti=(blocki-1)*trialsPerBlock+1; endi=blocki*trialsPerBlock;
        ContraFrontalvaluebyblock(blocki)=nanmean(ContraFrontalvaluebytrial(starti:endi));
    end

    % Somatosensory Contralateral
    for i=1:size(ContraS1ERP,2)
        ContraS1valuebytrial(i)=nanmean(ContraS1ERP(framestart:framestop,i));
    end
    ContraS1valuebyblock=nan(1,numBlocks);
    for blocki=1:numBlocks
        starti=(blocki-1)*trialsPerBlock+1; endi=blocki*trialsPerBlock;
        ContraS1valuebyblock(blocki)=nanmean(ContraS1valuebytrial(starti:endi));
    end

    % Frontal Ipsilateral
    for i=1:size(IpsiFrontalERP,2)
        IpsiFrontalvaluebytrial(i)=nanmean(IpsiFrontalERP(framestart:framestop,i));
    end
    IpsiFrontalvaluebyblock= nan(1,numBlocks);
    for blocki=1:numBlocks
        starti=(blocki-1)*trialsPerBlock+1; endi=blocki*trialsPerBlock;
        IpsiFrontalvaluebyblock(blocki)=nanmean(IpsiFrontalvaluebytrial(starti:endi));
    end

    % Somatosensory Ipsilateral
    for i=1:size(IpsiS1ERP,2)
        IpsiS1valuebytrial(i)=nanmean(IpsiS1ERP(framestart:framestop,i));
    end
    IpsiS1valuebyblock=nan(1,numBlocks);
    for blocki=1:numBlocks
        starti=(blocki-1)*trialsPerBlock+1; endi=blocki*trialsPerBlock;
        IpsiS1valuebyblock(blocki)=nanmean(IpsiS1valuebytrial(starti:endi));
    end

    if abs(mismatchRSContraFrontalvalue)>MMthreshold, mismatchRSContraFrontalvalue=NaN; end % Reject individual average ERPs when any value is above threshold (outlier)
    if abs(mismatchRSContraS1value)>MMthreshold, mismatchRSContraS1value=NaN; end
    if abs(mismatchRSIpsiFrontalvalue)>MMthreshold, mismatchRSIpsiFrontalvalue=NaN; end
    if abs(mismatchRSIpsiS1value)>MMthreshold, mismatchRSIpsiS1value=NaN; end

    %% Saving all RS results
    RSmismatchname=[rootname '_RS.mat'];
    save(RSmismatchname,'RSContraFrontal','RSContraS1','RSIpsiFrontal','RSIpsiS1',...
        'minContraFrontalERPFam','minContraFrontalERPControl','minContraS1ERPFam','minContraS1ERPControl','minIpsiFrontalERPFam',...
        'minIpsiFrontalERPControl','minIpsiS1ERPFam','minIpsiS1ERPControl',...
        'mismatchRSContraFrontalvalue','mismatchRSContraS1value','mismatchRSIpsiFrontalvalue','mismatchRSIpsiS1value',...
        'ContraFrontalvaluebyblock','ContraS1valuebyblock','IpsiFrontalvaluebyblock','IpsiS1valuebyblock');
end
clearvars -except framestart framestop smooth MMthreshold peakstudied;

%% Deviant vs. Stantard matched blocks

file_list=dir('*_Deviant_avgERPs.mat');
num_files=length(file_list);

for diri=1:num_files

    % load Deviant and Standard matched to deviant average ERPs

    Deviantfilename = file_list(diri).name; fprintf('Processing %s\n', Deviantfilename);
    rootname = extractBefore(Deviantfilename,'Deviant_avgERPs.mat');
    MatchedStdfilename = [rootname 'Standard matched to deviant_avgERPs.mat'];
    AllDevianttrialsfilename = [rootname 'Deviant_alltrialsERPs.mat'];

    load(Deviantfilename);
    avgContraFrontalERPDeviant=avgContraFrontalERP; avgContraS1ERPDeviant=avgContraS1ERP;
    avgIpsiFrontalERPDeviant=avgIpsiFrontalERP; avgIpsiS1ERPDeviant=avgIpsiS1ERP;
    clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

    load(MatchedStdfilename);
    avgContraFrontalERPMatchedStd=avgContraFrontalERP; avgContraS1ERPMatchedStd=avgContraS1ERP;
    avgIpsiFrontalERPMatchedStd=avgIpsiFrontalERP; avgIpsiS1ERPMatchedStd=avgIpsiS1ERP;
    clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

    % calculate mismatch traces
    DevMMContraFrontal=avgContraFrontalERPDeviant-avgContraFrontalERPMatchedStd;
    DevMMContraS1=avgContraS1ERPDeviant-avgContraS1ERPMatchedStd;
    DevMMIpsiFrontal=avgIpsiFrontalERPDeviant-avgIpsiFrontalERPMatchedStd;
    DevMMIpsiS1=avgIpsiS1ERPDeviant-avgIpsiS1ERPMatchedStd;

    % load all Deviant trials
    load(AllDevianttrialsfilename);

    % Frontal Contralateral
    if peakstudied==1
        [maxContraFrontalDevMMvalue,maxContraFrontalDevMMidx]=max(avgContraFrontalERPDeviant(framestart:framestop));
    elseif peakstudied==2
        [maxContraFrontalDevMMvalue,maxContraFrontalDevMMidx]=min(avgContraFrontalERPDeviant(framestart:framestop));
    end
    minContraFrontalERPDev=mean(avgContraFrontalERPDeviant(fix(framestart+maxContraFrontalDevMMidx-smooth):fix(framestart+maxContraFrontalDevMMidx+smooth)));
    minContraFrontalERPMstd=mean(avgContraFrontalERPMatchedStd(fix(framestart+maxContraFrontalDevMMidx-smooth):fix(framestart+maxContraFrontalDevMMidx+smooth)));
    mismatchDevMMContraFrontalvalue=minContraFrontalERPDev-minContraFrontalERPMstd;

    % S1 Contralateral
    if peakstudied==1
        [maxContraS1DevMMvalue,maxContraS1DevMMidx]=max(avgContraS1ERPDeviant(framestart:framestop));
    elseif peakstudied==2
        [maxContraS1DevMMvalue,maxContraS1DevMMidx]=min(avgContraS1ERPDeviant(framestart:framestop));
    end
    minContraS1ERPDev=mean(avgContraS1ERPDeviant(fix(framestart+maxContraS1DevMMidx-smooth):fix(framestart+maxContraS1DevMMidx+smooth)));
    minContraS1ERPMstd=mean(avgContraS1ERPMatchedStd(fix(framestart+maxContraS1DevMMidx-smooth):fix(framestart+maxContraS1DevMMidx+smooth)));
    mismatchDevMMContraS1value=minContraS1ERPDev-minContraS1ERPMstd;

    % Frontal Ipsilateral
    if peakstudied==1
        [maxIpsiFrontalDevMMvalue,maxIpsiFrontalDevMMidx]=max(avgIpsiFrontalERPDeviant(framestart:framestop));
    elseif peakstudied==2
        [maxIpsiFrontalDevMMvalue,maxIpsiFrontalDevMMidx]=min(avgIpsiFrontalERPDeviant(framestart:framestop));
    end
    minIpsiFrontalERPDev=mean(avgIpsiFrontalERPDeviant(fix(framestart+maxIpsiFrontalDevMMidx-smooth):fix(framestart+maxIpsiFrontalDevMMidx+smooth)));
    minIpsiFrontalERPMstd=mean(avgIpsiFrontalERPMatchedStd(fix(framestart+maxIpsiFrontalDevMMidx-smooth):fix(framestart+maxIpsiFrontalDevMMidx+smooth)));
    mismatchDevMMIpsiFrontalvalue=minIpsiFrontalERPDev-minIpsiFrontalERPMstd;

    % Somatosensory Ipsilateral
    if peakstudied==1
        [maxIpsiS1DevMMvalue,maxIpsiS1DevMMidx]=max(avgIpsiS1ERPDeviant(framestart:framestop));
    elseif peakstudied==2
        [maxIpsiS1DevMMvalue,maxIpsiS1DevMMidx]=min(avgIpsiS1ERPDeviant(framestart:framestop));
    end
    minIpsiS1ERPDev=mean(avgIpsiS1ERPDeviant(fix(framestart+maxIpsiS1DevMMidx-smooth):fix(framestart+maxIpsiS1DevMMidx+smooth)));
    minIpsiS1ERPMstd=mean(avgIpsiS1ERPMatchedStd(fix(framestart+maxIpsiS1DevMMidx-smooth):fix(framestart+maxIpsiS1DevMMidx+smooth)));
    mismatchDevMMIpsiS1value=minIpsiS1ERPDev-minIpsiS1ERPMstd;

    if abs(mismatchDevMMContraFrontalvalue)>MMthreshold, mismatchDevMMContraFrontalvalue=NaN; end % Reject individual average ERPs when any value is above threshold (outlier)
    if abs(mismatchDevMMContraS1value)>MMthreshold, mismatchDevMMContraS1value=NaN; end
    if abs(mismatchDevMMIpsiFrontalvalue)>MMthreshold, mismatchDevMMIpsiFrontalvalue=NaN; end
    if abs(mismatchDevMMIpsiS1value)>MMthreshold, mismatchDevMMIpsiS1value=NaN; end

    %% Saving all Deviance results
    DevMMmismatchname=[rootname 'DevMM.mat'];
    save(DevMMmismatchname,'DevMMContraFrontal','DevMMContraS1','DevMMIpsiFrontal','DevMMIpsiS1',...
        'minContraFrontalERPDev','minContraFrontalERPMstd','minContraS1ERPDev','minContraS1ERPMstd',...
        'minIpsiFrontalERPDev','minIpsiFrontalERPMstd','minIpsiS1ERPDev','minIpsiS1ERPMstd',...
        'mismatchDevMMContraFrontalvalue','mismatchDevMMContraS1value',...
        'mismatchDevMMIpsiFrontalvalue','mismatchDevMMIpsiS1value');

end
clearvars -except framestart framestop smooth MMthreshold peakstudied;

%% Post-omission vs. Stantard matched blocks

file_list=dir('*_Postomission_avgERPs.mat');
num_files=length(file_list);

for diri=1:num_files

    % load Postomission and Standard matched to deviant average ERPs

    Postomissionfilename = file_list(diri).name; fprintf('Processing %s\n', Postomissionfilename);
    rootname = extractBefore(Postomissionfilename,'Postomission_avgERPs.mat');
    MatchedStdfilename = [rootname 'Standard matched to deviant_avgERPs.mat'];
    AllPostomissiontrialsfilename = [rootname 'Postomission_alltrialsERPs.mat'];

    load(Postomissionfilename);
    avgContraFrontalERPPostomission=avgContraFrontalERP; avgContraS1ERPPostomission=avgContraS1ERP;
    avgIpsiFrontalERPPostomission=avgIpsiFrontalERP; avgIpsiS1ERPPostomission=avgIpsiS1ERP;
    clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

    load(MatchedStdfilename);
    avgContraFrontalERPMatchedStd=avgContraFrontalERP; avgContraS1ERPMatchedStd=avgContraS1ERP;
    avgIpsiFrontalERPMatchedStd=avgIpsiFrontalERP; avgIpsiS1ERPMatchedStd=avgIpsiS1ERP;
    clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

    % calculate mismatch traces
    PomMMContraFrontal=avgContraFrontalERPPostomission-avgContraFrontalERPMatchedStd;
    PomMMContraS1=avgContraS1ERPPostomission-avgContraS1ERPMatchedStd;
    PomMMIpsiFrontal=avgIpsiFrontalERPPostomission-avgIpsiFrontalERPMatchedStd;
    PomMMIpsiS1=avgIpsiS1ERPPostomission-avgIpsiS1ERPMatchedStd;

    % load all Postomission trials
    load(AllPostomissiontrialsfilename);

    % Frontal Contralateral
    if peakstudied==1
        [maxContraFrontalPomMMvalue,maxContraFrontalPomMMidx]=max(avgContraFrontalERPPostomission(framestart:framestop));
    elseif peakstudied==2
        [maxContraFrontalPomMMvalue,maxContraFrontalPomMMidx]=min(avgContraFrontalERPPostomission(framestart:framestop));
    end
    minContraFrontalERPPom=mean(avgContraFrontalERPPostomission(fix(framestart+maxContraFrontalPomMMidx-smooth):fix(framestart+maxContraFrontalPomMMidx+smooth)));
    minContraFrontalERPMstd=mean(avgContraFrontalERPMatchedStd(fix(framestart+maxContraFrontalPomMMidx-smooth):fix(framestart+maxContraFrontalPomMMidx+smooth)));
    mismatchPomMMContraFrontalvalue=minContraFrontalERPPom-minContraFrontalERPMstd;

    % S1 Contralateral
    if peakstudied==1
        [maxContraS1PomMMvalue,maxContraS1PomMMidx]=max(avgContraS1ERPPostomission(framestart:framestop));
    elseif peakstudied==2
        [maxContraS1PomMMvalue,maxContraS1PomMMidx]=min(avgContraS1ERPPostomission(framestart:framestop));
    end
    minContraS1ERPPom=mean(avgContraS1ERPPostomission(fix(framestart+maxContraS1PomMMidx-smooth):fix(framestart+maxContraS1PomMMidx+smooth)));
    minContraS1ERPMstd=mean(avgContraS1ERPMatchedStd(fix(framestart+maxContraS1PomMMidx-smooth):fix(framestart+maxContraS1PomMMidx+smooth)));
    mismatchPomMMContraS1value=minContraS1ERPPom-minContraS1ERPMstd;

    % Frontal Ipsilateral
    if peakstudied==1
        [maxIpsiFrontalPomMMvalue,maxIpsiFrontalPomMMidx]=max(avgIpsiFrontalERPPostomission(framestart:framestop));
    elseif peakstudied==2
        [maxIpsiFrontalPomMMvalue,maxIpsiFrontalPomMMidx]=min(avgIpsiFrontalERPPostomission(framestart:framestop));
    end
    minIpsiFrontalERPPom=mean(avgIpsiFrontalERPPostomission(fix(framestart+maxIpsiFrontalPomMMidx-smooth):fix(framestart+maxIpsiFrontalPomMMidx+smooth)));
    minIpsiFrontalERPMstd=mean(avgIpsiFrontalERPMatchedStd(fix(framestart+maxIpsiFrontalPomMMidx-smooth):fix(framestart+maxIpsiFrontalPomMMidx+smooth)));
    mismatchPomMMIpsiFrontalvalue=minIpsiFrontalERPPom-minIpsiFrontalERPMstd;

    % Somatosensory Ipsilateral
    if peakstudied==1
        [maxIpsiS1PomMMvalue,maxIpsiS1PomMMidx]=max(avgIpsiS1ERPPostomission(framestart:framestop));
    elseif peakstudied==2
        [maxIpsiS1PomMMvalue,maxIpsiS1PomMMidx]=min(avgIpsiS1ERPPostomission(framestart:framestop));
    end
    minIpsiS1ERPPom=mean(avgIpsiS1ERPPostomission(fix(framestart+maxIpsiS1PomMMidx-smooth):fix(framestart+maxIpsiS1PomMMidx+smooth)));
    minIpsiS1ERPMstd=mean(avgIpsiS1ERPMatchedStd(fix(framestart+maxIpsiS1PomMMidx-smooth):fix(framestart+maxIpsiS1PomMMidx+smooth)));
    mismatchPomMMIpsiS1value=minIpsiS1ERPPom-minIpsiS1ERPMstd;

    if abs(mismatchPomMMContraFrontalvalue)>MMthreshold, mismatchPomMMContraFrontalvalue=NaN; end % Reject individual average ERPs when any value is above threshold (outlier)
    if abs(mismatchPomMMContraS1value)>MMthreshold, mismatchPomMMContraS1value=NaN; end
    if abs(mismatchPomMMIpsiFrontalvalue)>MMthreshold, mismatchPomMMIpsiFrontalvalue=NaN; end
    if abs(mismatchPomMMIpsiS1value)>MMthreshold, mismatchPomMMIpsiS1value=NaN; end

    %% Saving all Postom results
    PomMMmismatchname=[rootname 'PomMM.mat'];
    save(PomMMmismatchname,'PomMMContraFrontal','PomMMContraS1','PomMMIpsiFrontal','PomMMIpsiS1',...
        'minContraFrontalERPPom','minContraFrontalERPMstd','minContraS1ERPPom','minContraS1ERPMstd',...
        'minIpsiFrontalERPPom','minIpsiFrontalERPMstd','minIpsiS1ERPPom','minIpsiS1ERPMstd',...
        'mismatchPomMMContraFrontalvalue','mismatchPomMMContraS1value',...
        'mismatchPomMMIpsiFrontalvalue','mismatchPomMMIpsiS1value');

end
clearvars -except framestart framestop peakstudied;