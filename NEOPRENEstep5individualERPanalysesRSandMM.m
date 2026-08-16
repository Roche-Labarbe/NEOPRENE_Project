%% NEOPRENE step 5 : ERP Analyses
% Run from folder containing _avgERPs.mat files (output from the NEOPRENEstep3ERPextraction.m script)
% This script calculates individual mismatch traces and values at a specific peak
% from avgERPs for all conditions, and saves individual _MM.mat and _RS.mat files for
% further analysis by script 6

close all
clear
clc

%% SETTINGS

load proc-settings.mat % processing parameters

%% define peak window for mismatch calculations

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

    if ((~contains(rootname,'2Y_')) && ((contains(rootname,'sub-17CE')||contains(rootname,'sub-20DD'))))
        controlexist=0; % sub-17 and sub-20 0Y, sub-61 at 2yo, do not have a control phase -> no RS
    else
        controlexist=1;
    end

    Controlfilename = [rootname '_Control_avgERPs.mat'];

    %% For RS between Familiarization vs Control phases
    load(Famfilename);
    avgContraFrontalERPFam=avgContraFrontalERP; avgContraS1ERPFam=avgContraS1ERP;
    avgIpsiFrontalERPFam=avgIpsiFrontalERP; avgIpsiS1ERPFam=avgIpsiS1ERP;

    lenseg=length(avgContraFrontalERPFam);
    
    clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

    if controlexist==1
        
        load(Controlfilename);
        avgContraFrontalERPControl=avgContraFrontalERP; avgContraS1ERPControl=avgContraS1ERP;
        avgIpsiFrontalERPControl=avgIpsiFrontalERP; avgIpsiS1ERPControl=avgIpsiS1ERP;
        clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

        % calculate RS / mismatch traces
        RSContraFrontal=avgContraFrontalERPFam-avgContraFrontalERPControl;
        RSContraS1=avgContraS1ERPFam-avgContraS1ERPControl;
        RSIpsiFrontal=avgIpsiFrontalERPFam-avgIpsiFrontalERPControl;
        RSIpsiS1=avgIpsiS1ERPFam-avgIpsiS1ERPControl;

    elseif controlexist==0
        
        avgContraFrontalERPControl(1:lenseg)=NaN; avgContraS1ERPControl(1:lenseg)=NaN;
        avgIpsiFrontalERPControl(1:lenseg)=NaN; avgIpsiS1ERPControl(1:lenseg)=NaN;

        RSContraFrontal(1:lenseg)=NaN; RSContraS1(1:lenseg)=NaN;
        RSIpsiFrontal(1:lenseg)=NaN; RSIpsiS1(1:lenseg)=NaN;

    end

    %% Mismatch calculations : looks for the peak at the test condition, and substract the value at the same latency on the control condition
    % Then I added a latency calculation

    % Frontal Contralateral
    if peakstudied==1 % positive
        [maxContraFrontalFamvalue,maxContraFrontalFamIdx]=max(avgContraFrontalERPFam(framestart:framestop)); % finds peak Fam value
        [maxContraFrontalControlvalue,maxContraFrontalControlIdx]=max(avgContraFrontalERPControl(framestart:framestop)); % finds peak Control value (for latency calculation, not for RS)
    elseif peakstudied==2 % negative
        [maxContraFrontalFamvalue,maxContraFrontalFamIdx]=min(avgContraFrontalERPFam(framestart:framestop));
        [maxContraFrontalControlvalue,maxContraFrontalControlIdx]=min(avgContraFrontalERPControl(framestart:framestop));
    end
    % get Fam latency at peak (called "min..." because I initially coded this for a negative component X-)
    minContraFrontalERPFam=mean(avgContraFrontalERPFam(fix(framestart+maxContraFrontalFamIdx-smooth):fix(framestart+maxContraFrontalFamIdx+smooth)));
    % get control value at the same latency
    minContraFrontalERPControl=mean(avgContraFrontalERPControl(fix(framestart+maxContraFrontalFamIdx-smooth):fix(framestart+maxContraFrontalFamIdx+smooth)));
    % calculate mismatch (RS)
    mismatchRSContraFrontalvalue=minContraFrontalERPFam-minContraFrontalERPControl;

    % get Fam latency if peak value exists
    if isnan (avgContraFrontalERPFam), ContraFrontalFamLatency = NaN;
    else ContraFrontalFamLatency = fix((ERPwindowstart+(maxContraFrontalFamIdx-1)/samplingrate)*1000);
    end
    % get Control latency
    if isnan (avgContraFrontalERPControl), ContraFrontalControlLatency = NaN;
    else ContraFrontalControlLatency = fix((ERPwindowstart+(maxContraFrontalControlIdx-1)/samplingrate)*1000);
    end

    % S1 Contralateral
    if peakstudied==1
        [maxContraS1Famvalue,maxContraS1FamIdx]=max(avgContraS1ERPFam(framestart:framestop));
        [maxContraS1Controlvalue,maxContraS1ControlIdx]=max(avgContraS1ERPControl(framestart:framestop));
    elseif peakstudied==2
        [maxContraS1Famvalue,maxContraS1FamIdx]=min(avgContraS1ERPFam(framestart:framestop));
        [maxContraS1Controlvalue,maxContraS1ControlIdx]=min(avgContraS1ERPControl(framestart:framestop));
    end
    minContraS1ERPFam=mean(avgContraS1ERPFam(fix(framestart+maxContraS1FamIdx-smooth):fix(framestart+maxContraS1FamIdx+smooth)));
    minContraS1ERPControl=mean(avgContraS1ERPControl(fix(framestart+maxContraS1FamIdx-smooth):fix(framestart+maxContraS1FamIdx+smooth)));
    mismatchRSContraS1value=minContraS1ERPFam-minContraS1ERPControl;

    if isnan (avgContraS1ERPFam), ContraS1FamLatency = NaN;
    else ContraS1FamLatency = fix((ERPwindowstart+(maxContraS1FamIdx-1)/samplingrate)*1000);
    end
    if isnan (avgContraS1ERPControl), ContraS1ControlLatency = NaN;
    else ContraS1ControlLatency = fix((ERPwindowstart+(maxContraS1ControlIdx-1)/samplingrate)*1000);
    end

    % Frontal Ipsilateral
    if peakstudied==1
        [maxIpsiFrontalFamvalue,maxIpsiFrontalFamIdx]=max(avgIpsiFrontalERPFam(framestart:framestop));
        [maxIpsiFrontalControlvalue,maxIpsiFrontalControlIdx]=max(avgIpsiFrontalERPControl(framestart:framestop));
    elseif peakstudied==2
        [maxIpsiFrontalFamvalue,maxIpsiFrontalFamIdx]=min(avgIpsiFrontalERPFam(framestart:framestop));
        [maxIpsiFrontalControlvalue,maxIpsiFrontalControlIdx]=min(avgIpsiFrontalERPControl(framestart:framestop));
    end
    minIpsiFrontalERPFam=mean(avgIpsiFrontalERPFam(fix(framestart+maxIpsiFrontalFamIdx-smooth):fix(framestart+maxIpsiFrontalFamIdx+smooth)));
    minIpsiFrontalERPControl=mean(avgIpsiFrontalERPControl(fix(framestart+maxIpsiFrontalFamIdx-smooth):fix(framestart+maxIpsiFrontalFamIdx+smooth)));
    mismatchRSIpsiFrontalvalue=minIpsiFrontalERPFam-minIpsiFrontalERPControl;

    if isnan (avgIpsiFrontalERPFam), IpsiFrontalFamLatency = NaN;
    else IpsiFrontalFamLatency = fix((ERPwindowstart+(maxIpsiFrontalFamIdx-1)/samplingrate)*1000);
    end
    if isnan (avgIpsiFrontalERPControl), IpsiFrontalControlLatency = NaN;
    else IpsiFrontalControlLatency = fix((ERPwindowstart+(maxIpsiFrontalControlIdx-1)/samplingrate)*1000);
    end

    % Somatosensory Ipsilateral
    if peakstudied==1
        [maxIpsiS1Famvalue,maxIpsiS1FamIdx]=max(avgIpsiS1ERPFam(framestart:framestop));
        [maxIpsiS1Controlvalue,maxIpsiS1ControlIdx]=max(avgIpsiS1ERPControl(framestart:framestop));
    elseif peakstudied==2
        [maxIpsiS1Famvalue,maxIpsiS1FamIdx]=min(avgIpsiS1ERPFam(framestart:framestop));
        [maxIpsiS1Controlvalue,maxIpsiS1ControlIdx]=min(avgIpsiS1ERPControl(framestart:framestop));
    end
    minIpsiS1ERPFam=mean(avgIpsiS1ERPFam(fix(framestart+maxIpsiS1FamIdx-smooth):fix(framestart+maxIpsiS1FamIdx+smooth)));
    minIpsiS1ERPControl=mean(avgIpsiS1ERPControl(fix(framestart+maxIpsiS1FamIdx-smooth):fix(framestart+maxIpsiS1FamIdx+smooth)));
    mismatchRSIpsiS1value=minIpsiS1ERPFam-minIpsiS1ERPControl;

    if isnan (avgIpsiS1ERPFam), IpsiS1FamLatency = NaN;
    else IpsiS1FamLatency = fix((ERPwindowstart+(maxIpsiS1FamIdx-1)/samplingrate)*1000);
    end
    if isnan (avgIpsiS1ERPControl), IpsiS1ControlLatency = NaN;
    else IpsiS1ControlLatency = fix((ERPwindowstart+(maxIpsiS1ControlIdx-1)/samplingrate)*1000);
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
        'minContraFrontalERPFam','ContraFrontalFamLatency','minContraFrontalERPControl','ContraFrontalControlLatency',...
        'minContraS1ERPFam','ContraS1FamLatency','minContraS1ERPControl','ContraS1ControlLatency',...
        'minIpsiFrontalERPFam','IpsiFrontalFamLatency','minIpsiFrontalERPControl','IpsiFrontalControlLatency',...
        'minIpsiS1ERPFam','IpsiS1FamLatency','minIpsiS1ERPControl','IpsiS1ControlLatency',...
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