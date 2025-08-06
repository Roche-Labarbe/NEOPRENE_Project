%% NEOPRENE step 6 : Group results for MM and RS
% Run from folder containing individual _RS.mat and _MM.mat files (output from the NEOPRENEstep4ERPanalysis.m script)
% This script groups individual peak values and mismatch values (at the peak chosen in script 4), avg mismatch traces by ROI for all subjects,
% and saves group RS.xlsx and MM.xlxs files also containing corresponding clinical factors

close all
clear all
clc

%% SETTINGS

load proc-settings.mat % processing parameters

time=(-baseline*initialSR):(initialSR/samplingrate):((postonset*initialSR)-(initialSR/samplingrate));

load('Clinical-variables.mat');

%% Repetition suppression

AllRSvalues=table('RowNames',{'ContraFrontal_Fam_peak','ContraFrontal_Control_peak','ContraS1_Fam_peak','ContraS1_Control_peak',...
    'IpsiFrontal_Fam_peak','IpsiFrontal_Control_peak','IpsiS1_Fam_peak','IpsiS1_Control_peak', ...
    'RSContraFrontal','RSContraS1','RSIpsiFrontal','RSIpsiS1',...
    'ContraFrontal_Fam_1to10','ContraFrontal_Fam_11to20','ContraFrontal_Fam_21to30','ContraFrontal_Fam_31to40',...
    'ContraS1_Fam_1to10','ContraS1_Fam_11to20','ContraS1_Fam_21to30','ContraS1_Fam_31to40',...
    'IpsiFrontal_Fam_1to10','IpsiFrontal_Fam_11to20','IpsiFrontal_Fam_21to30','IpsiFrontal_Fam_31to40',...
    'IpsiS1_Fam_1to10','IpsiS1_Fam_11to20','IpsiS1_Fam_21to30','IpsiS1_Fam_31to40'});

AllRSContraFrontal=table('RowNames',string(time)); AllRSContraS1=table('RowNames',string(time));
AllRSIpsiFrontal=table('RowNames',string(time)); AllRSIpsiS1=table('RowNames',string(time));

file_list=dir('*_RS.mat');
num_files=length(file_list);

% populate group tables
for diri=1:num_files

    datafilename=file_list(diri).name; load(datafilename); % load individual RS results
    fprintf('Processing %s\n', datafilename);
    subject=extractBefore(datafilename,'_RS.mat');

    AllRSvalues.(subject)=[minContraFrontalERPFam;minContraFrontalERPControl;minContraS1ERPFam;minContraS1ERPControl;...
        minIpsiFrontalERPFam;minIpsiFrontalERPControl;minIpsiS1ERPFam;minIpsiS1ERPControl;...
        mismatchRSContraFrontalvalue;mismatchRSContraS1value;mismatchRSIpsiFrontalvalue;mismatchRSIpsiS1value;...
        ContraFrontalvaluebyblock';ContraS1valuebyblock';IpsiFrontalvaluebyblock';IpsiS1valuebyblock'];
    AllRSContraFrontal.(subject)=RSContraFrontal; AllRSContraS1.(subject)=RSContraS1;
    AllRSIpsiFrontal.(subject)=RSIpsiFrontal; AllRSIpsiS1.(subject)=RSIpsiS1;

end

% Calculate RS grand averages
AllRSvalues.grandAvg=nanmean(AllRSvalues{:,:},2);
AllRSContraFrontal.grandAvg=nanmean(AllRSContraFrontal{:,:},2);
AllRSContraS1.grandAvg=nanmean(AllRSContraS1{:,:},2);
AllRSIpsiFrontal.grandAvg=nanmean(AllRSIpsiFrontal{:,:},2);
AllRSIpsiS1.grandAvg=nanmean(AllRSIpsiS1{:,:},2);

% Add clinical factors
for subi=1:size(AllRSvalues,2)
    for factori=1:size(Factors,1)
        if contains(AllRSvalues.Properties.VariableNames{subi},Factors.Subject(factori))
            AllRSvalues{'GA',subi}=Factors.GA(factori);
            AllRSvalues{'Pain',subi}=Factors.Pain(factori);
            AllRSvalues{'SleepQ',subi}=Factors.SleepQ(factori);
            AllRSvalues{'ASQ',subi}=Factors.ASQ(factori);
            AllRSvalues{'BRIEF',subi}=Factors.BRIEF(factori);
            AllRSvalues{'FSPseeking',subi}=Factors.FSPseeking(factori);
            AllRSvalues{'FSPavoidant',subi}=Factors.FSPavoidant(factori);
            AllRSvalues{'FSPsensitive',subi}=Factors.FSPsensitive(factori);
            AllRSvalues{'FSPregistering',subi}=Factors.FSPregistering(factori);
            AllRSvalues{'ActiNightSleep',subi}=Factors.ActiNightSleep(factori);
            AllRSvalues{'ActiNapSleep',subi}=Factors.ActiNapSleep(factori);
            AllRSvalues{'ActiTotalSleep',subi}=Factors.ActiTotalSleep(factori);
            AllRSvalues{'ActiSleepEfficiency',subi}=Factors.ActiSleepEfficiency(factori);
        end
    end
end
clear subi factori diri

% Save the tables to an Excel file
writetable(rows2vars(AllRSvalues),'RS.xlsx', 'Sheet', 'RS values','WriteRowNames', true);
writetable(AllRSContraFrontal, 'RS.xlsx', 'Sheet', 'RS Contra Frontal','WriteRowNames', true);
writetable(AllRSContraS1, 'RS.xlsx', 'Sheet', 'RS Contra S1','WriteRowNames', true);
writetable(AllRSIpsiFrontal, 'RS.xlsx', 'Sheet', 'RS Ipsi Frontal','WriteRowNames', true);
writetable(AllRSIpsiS1, 'RS.xlsx', 'Sheet', 'RS Ipsi S1', 'WriteRowNames', true);

%% Deviance detection

AllDevMMvalues=table('RowNames', {'ContraFrontal_Dev_peak','ContraFrontal_MatchedStd_peak','ContraS1_Dev_peak','ContraS1_MatchedStd_peak',...
    'IpsiFrontal_Dev_peak','IpsiFrontal_MatchedStd_peak','IpsiS1_Dev_peak','IpsiS1_MatchedStd_peak',...
    'DevMMContraFrontal','DevMMContraS1','DevMMIpsiFrontal','DevMMIpsiS1'});
AllDevMMContraFrontal=table('RowNames',string(time)); AllDevMMContraS1=table('RowNames',string(time));
AllDevMMIpsiFrontal=table('RowNames',string(time)); AllDevMMIpsiS1=table('RowNames',string(time));

file_list=dir('*DevMM.mat');
num_files=length(file_list);

% populate group tables
for diri=1:num_files

    datafilename=file_list(diri).name; load(datafilename); % load individual DevMM results
    fprintf('Processing %s\n', datafilename);
    subject=extractBefore(datafilename,'_DevMM.mat');

    AllDevMMvalues.(subject)=[minContraFrontalERPDev;minContraFrontalERPMstd;minContraS1ERPDev;minContraS1ERPMstd;...
        minIpsiFrontalERPDev;minIpsiFrontalERPMstd;minIpsiS1ERPDev;minIpsiS1ERPMstd;...
        mismatchDevMMContraFrontalvalue;mismatchDevMMContraS1value;...
        mismatchDevMMIpsiFrontalvalue;mismatchDevMMIpsiS1value];
    AllDevMMContraFrontal.(subject)=DevMMContraFrontal; AllDevMMContraS1.(subject)=DevMMContraS1;
    AllDevMMIpsiFrontal.(subject)=DevMMIpsiFrontal; AllDevMMIpsiS1.(subject)=DevMMIpsiS1;

end

% Calculate Deviance MM grand averages
AllDevMMvalues.grandAvg=nanmean(AllDevMMvalues{:,:},2);
AllDevMMContraFrontal.grandAvg=nanmean(AllDevMMContraFrontal{:,:},2);
AllDevMMContraS1.grandAvg=nanmean(AllDevMMContraS1{:,:},2);
AllDevMMIpsiFrontal.grandAvg=nanmean(AllDevMMIpsiFrontal{:,:},2);
AllDevMMIpsiS1.grandAvg=nanmean(AllDevMMIpsiS1{:,:},2);

% Add clinical factors
for subi=1:size(AllDevMMvalues,2)
    for factori=1:size(Factors,1)
        if contains(AllDevMMvalues.Properties.VariableNames{subi},Factors.Subject(factori))
            AllDevMMvalues{'GA',subi}=Factors.GA(factori);
            AllDevMMvalues{'Pain',subi}=Factors.Pain(factori);
            AllDevMMvalues{'SleepQ',subi}=Factors.SleepQ(factori);
            AllDevMMvalues{'ASQ',subi}=Factors.ASQ(factori);
            AllDevMMvalues{'BRIEF',subi}=Factors.BRIEF(factori);
            AllDevMMvalues{'FSPseeking',subi}=Factors.FSPseeking(factori);
            AllDevMMvalues{'FSPavoidant',subi}=Factors.FSPavoidant(factori);
            AllDevMMvalues{'FSPsensitive',subi}=Factors.FSPsensitive(factori);
            AllDevMMvalues{'FSPregistering',subi}=Factors.FSPregistering(factori);
            AllDevMMvalues{'ActiNightSleep',subi}=Factors.ActiNightSleep(factori);
            AllDevMMvalues{'ActiNapSleep',subi}=Factors.ActiNapSleep(factori);
            AllDevMMvalues{'ActiTotalSleep',subi}=Factors.ActiTotalSleep(factori);
            AllDevMMvalues{'ActiSleepEfficiency',subi}=Factors.ActiSleepEfficiency(factori);
        end
    end
end
clear subi factori diri

% Save the tables to an Excel file
writetable(rows2vars(AllDevMMvalues),'DevMM.xlsx', 'Sheet', 'DevMM values','WriteRowNames', true);
writetable(AllDevMMContraFrontal, 'DevMM.xlsx', 'Sheet', 'DevMM Contra Frontal','WriteRowNames', true);
writetable(AllDevMMContraS1, 'DevMM.xlsx', 'Sheet', 'DevMM Contra S1','WriteRowNames', true);
writetable(AllDevMMIpsiFrontal, 'DevMM.xlsx', 'Sheet', 'DevMM Ipsi Frontal','WriteRowNames', true);
writetable(AllDevMMIpsiS1, 'DevMM.xlsx', 'Sheet', 'DevMM Ipsi S1', 'WriteRowNames', true);

%% Postomission (omission detection)

AllPomMMvalues=table('RowNames', { 'ContraFrontal_Postom_peak','ContraFrontal_MatchedStd_peak','ContraS1_Postom_peak','ContraS1_MatchedStd_peak',...
    'IpsiFrontal_Postom_peak','IpsiFrontal_MatchedStd_peak','IpsiS1_Postom_peak','IpsiS1_MatchedStd_peak',...
    'PomMMContraFrontal','PomMMContraS1','PomMMIpsiFrontal','PomMMIpsiS1'});
AllPomMMContraFrontal=table('RowNames',string(time)); AllPomMMContraS1=table('RowNames',string(time));
AllPomMMIpsiFrontal=table('RowNames',string(time)); AllPomMMIpsiS1=table('RowNames',string(time));

file_list=dir('*PomMM.mat');
num_files=length(file_list);

% populate group tables
for diri=1:num_files

    datafilename=file_list(diri).name; load(datafilename); % load individual Postomission MM results
    fprintf('Processing %s\n', datafilename);
    subject=extractBefore(datafilename,'_PomMM.mat');

    AllPomMMvalues.(subject)=[minContraFrontalERPPom;minContraFrontalERPMstd;minContraS1ERPPom;minContraS1ERPMstd;...
        minIpsiFrontalERPPom;minIpsiFrontalERPMstd;minIpsiS1ERPPom;minIpsiS1ERPMstd;...
        mismatchPomMMContraFrontalvalue;mismatchPomMMContraS1value;...
        mismatchPomMMIpsiFrontalvalue;mismatchPomMMIpsiS1value];
    AllPomMMContraFrontal.(subject)=PomMMContraFrontal; AllPomMMContraS1.(subject)=PomMMContraS1;
    AllPomMMIpsiFrontal.(subject)=PomMMIpsiFrontal; AllPomMMIpsiS1.(subject)=PomMMIpsiS1;

end

% Calculate Postomission MM grand averages
AllPomMMvalues.grandAvg=nanmean(AllPomMMvalues{:,:},2);
AllPomMMContraFrontal.grandAvg=nanmean(AllPomMMContraFrontal{:,:},2);
AllPomMMContraS1.grandAvg=nanmean(AllPomMMContraS1{:,:},2);
AllPomMMIpsiFrontal.grandAvg=nanmean(AllPomMMIpsiFrontal{:,:},2);
AllPomMMIpsiS1.grandAvg=nanmean(AllPomMMIpsiS1{:,:},2);

% Add clinical factors
for subi=1:size(AllPomMMvalues,2)
    for factori=1:size(Factors,1)
        if contains(AllPomMMvalues.Properties.VariableNames{subi},Factors.Subject(factori))
            AllPomMMvalues{'GA',subi}=Factors.GA(factori);
            AllPomMMvalues{'Pain',subi}=Factors.Pain(factori);
            AllPomMMvalues{'SleepQ',subi}=Factors.SleepQ(factori);
            AllPomMMvalues{'ASQ',subi}=Factors.ASQ(factori);
            AllPomMMvalues{'BRIEF',subi}=Factors.BRIEF(factori);
            AllPomMMvalues{'FSPseeking',subi}=Factors.FSPseeking(factori);
            AllPomMMvalues{'FSPavoidant',subi}=Factors.FSPavoidant(factori);
            AllPomMMvalues{'FSPsensitive',subi}=Factors.FSPsensitive(factori);
            AllPomMMvalues{'FSPregistering',subi}=Factors.FSPregistering(factori);
            AllPomMMvalues{'ActiNightSleep',subi}=Factors.ActiNightSleep(factori);
            AllPomMMvalues{'ActiNapSleep',subi}=Factors.ActiNapSleep(factori);
            AllPomMMvalues{'ActiTotalSleep',subi}=Factors.ActiTotalSleep(factori);
            AllPomMMvalues{'ActiSleepEfficiency',subi}=Factors.ActiSleepEfficiency(factori);
        end
    end
end
clear subi factori diri

% Save tables for further analysis in pretty statistics software
writetable(rows2vars(AllPomMMvalues),'PomMM.xlsx', 'Sheet', 'PomMM values','WriteRowNames', true);
writetable(AllPomMMContraFrontal, 'PomMM.xlsx', 'Sheet', 'PomMM Contra Frontal','WriteRowNames', true);
writetable(AllPomMMContraS1, 'PomMM.xlsx', 'Sheet', 'PomMM Contra S1','WriteRowNames', true);
writetable(AllPomMMIpsiFrontal, 'PomMM.xlsx', 'Sheet', 'PomMM Ipsi Frontal','WriteRowNames', true);
writetable(AllPomMMIpsiS1, 'PomMM.xlsx', 'Sheet', 'FrontalMM Ipsi S1', 'WriteRowNames', true);

%% Figures

% plot RS grand averages
figure('Name','All RS traces + grand averages')
subplot(2,2,1)
for i=1:(size(AllRSContraFrontal,2)-1), plot(time, AllRSContraFrontal{:,i},'b'); hold on; end
plot(time, AllRSContraFrontal{:,size(AllRSContraFrontal,2)}, 'k', 'LineWidth', 2); hold off
xlabel('Time'); title('Frontal contralateral cortex');
subplot(2,2,2)
for i=1:(size(AllRSContraS1,2)-1), plot(time, AllRSContraS1{:,i},'b'); hold on; end
plot(time, AllRSContraS1{:,size(AllRSContraS1,2)}, 'k', 'LineWidth', 2); hold off
xlabel('Time'); title('Somatosensory contralateral cortex');
subplot(2,2,3)
for i=1:(size(AllRSIpsiFrontal,2)-1), plot(time, AllRSIpsiFrontal{:,i},'b'); hold on; end
plot(time, AllRSIpsiFrontal{:,size(AllRSIpsiFrontal,2)}, 'k', 'LineWidth', 2); hold off
xlabel('Time'); title('Frontal ipsilateral cortex');
subplot(2,2,4)
for i=1:(size(AllRSIpsiS1,2)-1), plot(time, AllRSIpsiS1{:,i},'b'); hold on; end
plot(time, AllRSIpsiS1{:,size(AllRSIpsiS1,2)}, 'k', 'LineWidth', 2); hold off
xlabel('Time'); title('Somatosensory ispilateral cortex');

% plot Deviance Mismatch grand averages
figure('Name','All Deviant MMR + grand averages')
subplot(2,2,1)
for i=1:(size(AllDevMMContraFrontal,2)-1), plot(time, AllDevMMContraFrontal{:,i},'b'); hold on; end
plot(time, AllDevMMContraFrontal{:,size(AllDevMMContraFrontal,2)}, 'k', 'LineWidth', 2); hold off
xlabel('Time'); title('Frontal contralateral cortex');
subplot(2,2,2)
for i=1:(size(AllDevMMContraS1,2)-1), plot(time, AllDevMMContraS1{:,i},'b'); hold on; end
plot(time, AllDevMMContraS1{:,size(AllDevMMContraS1,2)}, 'k', 'LineWidth', 2); hold off
xlabel('Time'); title('Somatosensory contralateral cortex');
subplot(2,2,3)
for i=1:(size(AllDevMMIpsiFrontal,2)-1), plot(time, AllDevMMIpsiFrontal{:,i},'b'); hold on; end
plot(time, AllDevMMIpsiFrontal{:,size(AllDevMMIpsiFrontal,2)}, 'k', 'LineWidth', 2); hold off
xlabel('Time'); title('Frontal ipsilateral cortex');
subplot(2,2,4)
for i=1:(size(AllDevMMIpsiS1,2)-1), plot(time, AllDevMMIpsiS1{:,i},'b'); hold on; end
plot(time, AllDevMMIpsiS1{:,size(AllDevMMIpsiS1,2)}, 'k', 'LineWidth', 2); hold off
xlabel('Time'); title('Somatosensory ispilateral cortex');

% plot only grand avgs
figure('Name','All grand averages')
subplot(3,4,1)
plot(time, AllRSContraFrontal{:,size(AllRSContraFrontal,2)}, 'k', 'LineWidth', 2); hold on;
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]);
title('RS Frontal contralateral cortex');
subplot(3,4,2)
plot(time, AllRSContraS1{:,size(AllRSContraS1,2)}, 'k', 'LineWidth', 2); hold on;
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]); yline(0);
title('RS Somatosensory contralateral cortex');
subplot(3,4,3)
plot(time, AllRSIpsiFrontal{:,size(AllRSIpsiFrontal,2)}, 'k', 'LineWidth', 2); hold on
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]); yline(0);
title('RS Frontal ipsilateral cortex');
subplot(3,4,4)
plot(time, AllRSIpsiS1{:,size(AllRSIpsiS1,2)}, 'k', 'LineWidth', 2); hold on
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]); yline(0);
title('RS Somatosensory ispilateral cortex');
subplot(3,4,5)
plot(time, AllDevMMContraFrontal{:,size(AllDevMMContraFrontal,2)}, 'k', 'LineWidth', 2); hold on
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]); yline(0);
title('Deviance MM Frontal contralateral cortex');
subplot(3,4,6)
plot(time, AllDevMMContraS1{:,size(AllDevMMContraS1,2)}, 'k', 'LineWidth', 2); hold on
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]); yline(0);
title('Deviance MM Somatosensory contralateral cortex');
subplot(3,4,7)
plot(time, AllDevMMIpsiFrontal{:,size(AllDevMMIpsiFrontal,2)}, 'k', 'LineWidth', 2); hold on
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]); yline(0);
title('Deviance MM Frontal ipsilateral cortex');
subplot(3,4,8)
plot(time, AllDevMMIpsiS1{:,size(AllDevMMIpsiS1,2)}, 'k', 'LineWidth', 2); hold on
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]); yline(0);
title('Deviance MM Somatosensory ispilateral cortex');
subplot(3,4,9)
plot(time, AllPomMMContraFrontal{:,size(AllPomMMContraFrontal,2)}, 'k', 'LineWidth', 2); hold on
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]); yline(0);
title('Postomission MM Frontal contralateral cortex');
subplot(3,4,10)
plot(time, AllPomMMContraS1{:,size(AllPomMMContraS1,2)}, 'k', 'LineWidth', 2); hold on
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]); yline(0);
title('Postomission MM Somatosensory contralateral cortex');
subplot(3,4,11)
plot(time, AllPomMMIpsiFrontal{:,size(AllPomMMIpsiFrontal,2)}, 'k', 'LineWidth', 2); hold on
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]); yline(0);
title('Postomission MM Frontal ipsilateral cortex');
subplot(3,4,12)
plot(time, AllPomMMIpsiS1{:,size(AllPomMMIpsiS1,2)}, 'k', 'LineWidth', 2); hold on
xlabel('Time'); xlim([-200 1400]); ylabel('µV'); yline(0); ylim([-1 1]); yline(0);
title('Postomission MM Somatosensory ispilateral cortex');