%% NEOPRENE step 4 : Group and graphs ERPs by condition
% Run from folder containing ERPs.mat files (output from the NEOPRENEstep3ERPextraction.m script)
% This scripts graphs grand average ERPs and writes all individual ERPs in a single ERP.xlsx files

close all
clear all
clc

load proc-settings.mat % processing parameters

%% define peak search windows for highlighting on graphs

framestart1=fix((baseline+ERPwindowstart1)*samplingrate);
framestop1=fix((baseline+ERPwindowstop1)*samplingrate);

framestart2=fix((baseline+ERPwindowstart2)*samplingrate);
framestop2=fix((baseline+ERPwindowstop2)*samplingrate);

framestartOm=fix((baseline+ERPwindowstartOm)*samplingrate);
framestopOm=fix((baseline+ERPwindowstopOm)*samplingrate);

%% Prepare files

time=(-baseline*initialSR):(initialSR/samplingrate):((postonset*initialSR)-(initialSR/samplingrate));

GrandAvgContraFrontalERPFam=table('RowNames',string(time)); GrandAvgContraS1ERPFam=table('RowNames',string(time));
GrandAvgIpsiFrontalERPFam=table('RowNames',string(time)); GrandAvgIpsiS1ERPFam=table('RowNames',string(time));
GrandAvgContraFrontalERPControl=table('RowNames',string(time)); GrandAvgContraS1ERPControl=table('RowNames',string(time));
GrandAvgIpsiFrontalERPControl=table('RowNames',string(time)); GrandAvgIpsiS1ERPControl=table('RowNames',string(time));

GrandAvgContraFrontalERPDev=table('RowNames',string(time)); GrandAvgContraS1ERPDev=table('RowNames',string(time));
GrandAvgIpsiFrontalERPDev=table('RowNames',string(time)); GrandAvgIpsiS1ERPDev=table('RowNames',string(time));
GrandAvgContraFrontalERPMStd=table('RowNames',string(time)); GrandAvgContraS1ERPMStd=table('RowNames',string(time));
GrandAvgIpsiFrontalERPMStd=table('RowNames',string(time)); GrandAvgIpsiS1ERPMStd=table('RowNames',string(time));

GrandAvgContraFrontalERPPom=table('RowNames',string(time)); GrandAvgContraS1ERPPom=table('RowNames',string(time));
GrandAvgIpsiFrontalERPPom=table('RowNames',string(time)); GrandAvgIpsiS1ERPPom=table('RowNames',string(time));

GrandAvgContraFrontalERPOm=table('RowNames',string(time)); GrandAvgContraS1ERPOm=table('RowNames',string(time));
GrandAvgIpsiFrontalERPOm=table('RowNames',string(time)); GrandAvgIpsiS1ERPOm=table('RowNames',string(time));

%% Repetition suppression : grand average graphs of Familiarization vs. Control

file_list=dir('*Familiarization_avgERPs.mat');
num_files=length(file_list);

for diri=1:num_files

    % load Findividual amiliarization and Control average ERPs

    Famfilename = file_list(diri).name; fprintf('Processing %s\n', Famfilename);
    subject=extractBefore(Famfilename,'_Familiarization_avgERPs.mat');

    if ~contains(Famfilename,'sub-20DD') && ~contains(Famfilename,'sub-17CE')... % sub 17 and 20 at 0Y do not have Control markers because of bug during acquisition
            
        rootname = extractBefore(Famfilename,'Familiarization_avgERPs.mat');
        Controlfilename = [rootname 'Control_avgERPs.mat'];
        
        % Gather all individual averages for Familiarization and Control phases
        load(Famfilename);
        GrandAvgContraFrontalERPFam.(subject)=avgContraFrontalERP; GrandAvgContraS1ERPFam.(subject)=avgContraS1ERP;
        GrandAvgIpsiFrontalERPFam.(subject)=avgIpsiFrontalERP; GrandAvgIpsiS1ERPFam.(subject)=avgIpsiS1ERP;

        clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

        load(Controlfilename);
        GrandAvgContraFrontalERPControl.(subject)=avgContraFrontalERP; GrandAvgContraS1ERPControl.(subject)=avgContraS1ERP;
        GrandAvgIpsiFrontalERPControl.(subject)=avgIpsiFrontalERP; GrandAvgIpsiS1ERPControl.(subject)=avgIpsiS1ERP;

        clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

    end
end

%% calculate grand averages

GrandAvgContraFrontalERPFam.grandAvg=nanmean(GrandAvgContraFrontalERPFam{:,:},2);
GrandAvgContraS1ERPFam.grandAvg=nanmean(GrandAvgContraS1ERPFam{:,:},2);
GrandAvgIpsiFrontalERPFam.grandAvg=nanmean(GrandAvgIpsiFrontalERPFam{:,:},2);
GrandAvgIpsiS1ERPFam.grandAvg=nanmean(GrandAvgIpsiS1ERPFam{:,:},2);

GrandAvgContraFrontalERPControl.grandAvg=nanmean(GrandAvgContraFrontalERPControl{:,:},2);
GrandAvgContraS1ERPControl.grandAvg=nanmean(GrandAvgContraS1ERPControl{:,:},2);
GrandAvgIpsiFrontalERPControl.grandAvg=nanmean(GrandAvgIpsiFrontalERPControl{:,:},2);
GrandAvgIpsiS1ERPControl.grandAvg=nanmean(GrandAvgIpsiS1ERPControl{:,:},2);

%% Save the tables to an Excel file

writetable(GrandAvgContraFrontalERPFam, 'FamERP.xlsx', 'Sheet', 'ContraFrontal','WriteRowNames', true);
writetable(GrandAvgContraS1ERPFam, 'FamERP.xlsx', 'Sheet', 'ContraS1','WriteRowNames', true);
writetable(GrandAvgIpsiFrontalERPFam, 'FamERP.xlsx', 'Sheet', 'IpsiFrontal','WriteRowNames', true);
writetable(GrandAvgIpsiS1ERPFam, 'FamERP.xlsx', 'Sheet', 'IpsiS1','WriteRowNames', true);

writetable(GrandAvgContraFrontalERPControl, 'ControlERP.xlsx', 'Sheet', 'ContraFrontal','WriteRowNames', true);
writetable(GrandAvgContraS1ERPControl, 'ControlERP.xlsx', 'Sheet', 'ContraS1','WriteRowNames', true);
writetable(GrandAvgIpsiFrontalERPControl, 'ControlERP.xlsx', 'Sheet', 'IpsiFrontal','WriteRowNames', true);
writetable(GrandAvgIpsiS1ERPControl, 'ControlERP.xlsx', 'Sheet', 'IpsiS1','WriteRowNames', true);

%% plot grand avgs
figure('Name','Grand averages')
subplot(4,4,1)
plot(time,GrandAvgContraS1ERPFam.grandAvg, 'Color', [0, 0.8, 0.3], 'LineWidth', 2); hold on;
plot(time,GrandAvgContraS1ERPControl.grandAvg, 'Color', [0.5, 0, 1], 'LineWidth', 2);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgContraS1ERPControl.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgContraS1ERPFam.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgContraS1ERPControl.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgContraS1ERPFam.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-1.2 0.8]); yline(0); xlim([-300 900]); xline(0); xline(200); axis ij;
title('RS Somatosensory contralateral cortex');
subplot(4,4,2)
plot(time,GrandAvgContraFrontalERPFam.grandAvg, 'Color', [0, 0.8, 0.3], 'LineWidth', 2); hold on;
plot(time,GrandAvgContraFrontalERPControl.grandAvg, 'Color', [0.5, 0, 1], 'LineWidth', 2);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgContraFrontalERPControl.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgContraFrontalERPFam.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgContraFrontalERPControl.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgContraFrontalERPFam.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-0.8 1.2]); xlim([-300 900]); xline(0); xline(200); axis ij;
title('RS Frontal contralateral cortex');
subplot(4,4,3)
plot(time,GrandAvgIpsiFrontalERPFam.grandAvg, 'Color', [0, 0.8, 0.3], 'LineWidth', 2); hold on;
plot(time,GrandAvgIpsiFrontalERPControl.grandAvg, 'Color', [0.5, 0, 1], 'LineWidth', 2);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgIpsiFrontalERPControl.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgIpsiFrontalERPFam.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgIpsiFrontalERPControl.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgIpsiFrontalERPFam.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-1 1]); xlim([-300 900]); xline(0); xline(200); axis ij;
title('RS Frontal ipsilateral cortex');
subplot(4,4,4)
plot(time,GrandAvgIpsiS1ERPFam.grandAvg, 'Color', [0, 0.8, 0.3], 'LineWidth', 2); hold on;
plot(time,GrandAvgIpsiS1ERPControl.grandAvg, 'Color', [0.5, 0, 1], 'LineWidth', 2);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgIpsiS1ERPControl.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgIpsiS1ERPFam.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgIpsiS1ERPControl.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgIpsiS1ERPFam.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-1 1]); yline(0); xlim([-300 900]); xline(0); xline(200); axis ij;
title('RS Somatosensory ipsilateral cortex');

%% Deviance detection : grand average graphs of Deviants vs. Standard matched to deviants

file_list=dir('*_Deviant_avgERPs.mat');
num_files=length(file_list);

for diri=1:num_files

    % load individual Deviant and Standard matched to deviant average ERPs

    Devfilename = file_list(diri).name; fprintf('Processing %s\n', Devfilename);
    subject=extractBefore(Devfilename,'_Deviant_avgERPs.mat');

    rootname = extractBefore(Devfilename,'Deviant_avgERPs.mat');
    MStdfilename = [rootname 'Standard matched to deviant_avgERPs.mat'];

    % Gather all individual averages for Deviant and Standard matched to deviant trials
    load(Devfilename);
    GrandAvgContraFrontalERPDev.(subject)=avgContraFrontalERP; GrandAvgContraS1ERPDev.(subject)=avgContraS1ERP;
    GrandAvgIpsiFrontalERPDev.(subject)=avgIpsiFrontalERP; GrandAvgIpsiS1ERPDev.(subject)=avgIpsiS1ERP;

    clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

    load(MStdfilename);
    GrandAvgContraFrontalERPMStd.(subject)=avgContraFrontalERP; GrandAvgContraS1ERPMStd.(subject)=avgContraS1ERP;
    GrandAvgIpsiFrontalERPMStd.(subject)=avgIpsiFrontalERP; GrandAvgIpsiS1ERPMStd.(subject)=avgIpsiS1ERP;

    clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

end

%% calculate grand averages

GrandAvgContraFrontalERPDev.grandAvg=nanmean(GrandAvgContraFrontalERPDev{:,:},2);
GrandAvgContraS1ERPDev.grandAvg=nanmean(GrandAvgContraS1ERPDev{:,:},2);
GrandAvgIpsiFrontalERPDev.grandAvg=nanmean(GrandAvgIpsiFrontalERPDev{:,:},2);
GrandAvgIpsiS1ERPDev.grandAvg=nanmean(GrandAvgIpsiS1ERPDev{:,:},2);

GrandAvgContraFrontalERPMStd.grandAvg=nanmean(GrandAvgContraFrontalERPMStd{:,:},2);
GrandAvgContraS1ERPMStd.grandAvg=nanmean(GrandAvgContraS1ERPMStd{:,:},2);
GrandAvgIpsiFrontalERPMStd.grandAvg=nanmean(GrandAvgIpsiFrontalERPMStd{:,:},2);
GrandAvgIpsiS1ERPMStd.grandAvg=nanmean(GrandAvgIpsiS1ERPMStd{:,:},2);

%% Save the tables to an Excel file

writetable(GrandAvgContraFrontalERPDev, 'DevERP.xlsx', 'Sheet', 'ContraFrontal','WriteRowNames', true);
writetable(GrandAvgContraS1ERPDev, 'DevERP.xlsx', 'Sheet', 'ContraS1','WriteRowNames', true);
writetable(GrandAvgIpsiFrontalERPDev, 'DevERP.xlsx', 'Sheet', 'IpsiFrontal','WriteRowNames', true);
writetable(GrandAvgIpsiS1ERPDev, 'DevERP.xlsx', 'Sheet', 'IpsiS1','WriteRowNames', true);

writetable(GrandAvgContraFrontalERPMStd, 'MStdERP.xlsx', 'Sheet', 'ContraFrontal','WriteRowNames', true);
writetable(GrandAvgContraS1ERPMStd, 'MStdERP.xlsx', 'Sheet', 'ContraS1','WriteRowNames', true);
writetable(GrandAvgIpsiFrontalERPMStd, 'MStdERP.xlsx', 'Sheet', 'IpsiFrontal','WriteRowNames', true);
writetable(GrandAvgIpsiS1ERPMStd, 'MStdERP.xlsx', 'Sheet', 'IpsiS1','WriteRowNames', true);

%% plot grand avgs
subplot(4,4,5)
plot(time,GrandAvgContraS1ERPDev.grandAvg, 'Color', [0, 0.4, 0.8], 'LineWidth', 2); hold on;
plot(time,GrandAvgContraS1ERPMStd.grandAvg, 'k', 'LineWidth', 1);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgContraS1ERPMStd.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgContraS1ERPDev.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgContraS1ERPMStd.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgContraS1ERPDev.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-1.5 0.5]); xlim([-300 900]); xline(0); xline(200); axis ij;
title('Deviance Somatosensory contralateral cortex');
subplot(4,4,6)
plot(time,GrandAvgContraFrontalERPDev.grandAvg, 'Color', [0, 0.4, 0.8], 'LineWidth', 2); hold on;
plot(time,GrandAvgContraFrontalERPMStd.grandAvg, 'k', 'LineWidth', 1);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgContraFrontalERPMStd.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgContraFrontalERPDev.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgContraFrontalERPMStd.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgContraFrontalERPDev.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-1.5 0.5]); xlim([-300 900]); xline(0); xline(200); axis ij;
title('Deviance Frontal contralateral cortex');
subplot(4,4,7)
plot(time,GrandAvgIpsiFrontalERPDev.grandAvg, 'Color', [0, 0.4, 0.8], 'LineWidth', 2); hold on;
plot(time,GrandAvgIpsiFrontalERPMStd.grandAvg, 'k', 'LineWidth', 1);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgIpsiFrontalERPMStd.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgIpsiFrontalERPDev.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgIpsiFrontalERPMStd.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgIpsiFrontalERPDev.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-1 1]); xlim([-300 900]); xline(0); xline(200); axis ij;
title('Deviance Frontal ipsilateral cortex');
subplot(4,4,8)
plot(time,GrandAvgIpsiS1ERPDev.grandAvg, 'Color', [0, 0.4, 0.8], 'LineWidth', 2); hold on;
plot(time,GrandAvgIpsiS1ERPMStd.grandAvg, 'k', 'LineWidth', 1);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgIpsiS1ERPMStd.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgIpsiS1ERPDev.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgIpsiS1ERPMStd.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgIpsiS1ERPDev.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-1 1]); xlim([-300 900]); xline(0); xline(200); axis ij;
title('Deviance Somatosensory ipsilateral cortex');

%% Postomission : grand average graphs of Postom vs. Standard matched to deviants

file_list=dir('*_Postomission_avgERPs.mat');
num_files=length(file_list);

for diri=1:num_files

    % load individual Postomission average ERPs

    Pomfilename = file_list(diri).name; fprintf('Processing %s\n', Pomfilename);
    subject=extractBefore(Pomfilename,'_Postomission_avgERPs.mat');
    rootname = extractBefore(Pomfilename,'Postomission_avgERPs.mat');
    AllPomtrialsfilename = [rootname 'Postomission_alltrialsERPs.mat'];

    % Gather all individual averages for Postomission trials
    load(Pomfilename);
    GrandAvgContraFrontalERPPom.(subject)=avgContraFrontalERP; GrandAvgContraS1ERPPom.(subject)=avgContraS1ERP;
    GrandAvgIpsiFrontalERPPom.(subject)=avgIpsiFrontalERP; GrandAvgIpsiS1ERPPom.(subject)=avgIpsiS1ERP;

    clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

end

%% calculate grand averages
GrandAvgContraFrontalERPPom.grandAvg=nanmean(GrandAvgContraFrontalERPPom{:,:},2);
GrandAvgContraS1ERPPom.grandAvg=nanmean(GrandAvgContraS1ERPPom{:,:},2);
GrandAvgIpsiFrontalERPPom.grandAvg=nanmean(GrandAvgIpsiFrontalERPPom{:,:},2);
GrandAvgIpsiS1ERPPom.grandAvg=nanmean(GrandAvgIpsiS1ERPPom{:,:},2);

%% Save the tables to an Excel file
writetable(GrandAvgContraFrontalERPPom, 'PomERP.xlsx', 'Sheet', 'ContraFrontal','WriteRowNames', true);
writetable(GrandAvgContraS1ERPPom, 'PomERP.xlsx', 'Sheet', 'ContraS1','WriteRowNames', true);
writetable(GrandAvgIpsiFrontalERPPom, 'PomERP.xlsx', 'Sheet', 'IpsiFrontal','WriteRowNames', true);
writetable(GrandAvgIpsiS1ERPPom, 'PomERP.xlsx', 'Sheet', 'IpsiS1','WriteRowNames', true);

%% plot grand avgs (reusing Standard Matched to Deviant traces as the control here as well)
subplot(4,4,9)
plot(time,GrandAvgContraS1ERPPom.grandAvg, 'Color', [1, 0.5, 0], 'LineWidth', 2); hold on;
plot(time,GrandAvgContraS1ERPMStd.grandAvg, 'k', 'LineWidth', 1);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgContraS1ERPMStd.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgContraS1ERPPom.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgContraS1ERPMStd.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgContraS1ERPPom.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-1 1]); xlim([-300 900]); xline(0); xline(200); axis ij;
title('Postomission Somatosensory contralateral cortex');
subplot(4,4,10)
plot(time,GrandAvgContraFrontalERPPom.grandAvg, 'Color', [1, 0.5, 0], 'LineWidth', 2); hold on;
plot(time,GrandAvgContraFrontalERPMStd.grandAvg, 'k', 'LineWidth', 1);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgContraFrontalERPMStd.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgContraFrontalERPPom.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgContraFrontalERPMStd.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgContraFrontalERPPom.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-1 1]); xlim([-300 900]); xline(0); xline(200); axis ij;
title('Postomission Frontal contralateral cortex');
subplot(4,4,11)
plot(time,GrandAvgIpsiFrontalERPPom.grandAvg, 'Color', [1, 0.5, 0], 'LineWidth', 2); hold on;
plot(time,GrandAvgIpsiFrontalERPMStd.grandAvg, 'k', 'LineWidth', 1);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgIpsiFrontalERPMStd.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgIpsiFrontalERPPom.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgIpsiFrontalERPMStd.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgIpsiFrontalERPPom.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-1 1]); xlim([-300 900]); xline(0); xline(200); axis ij;
title('Postomission Frontal ipsilateral cortex');
subplot(4,4,12)
plot(time,GrandAvgIpsiS1ERPPom.grandAvg, 'Color', [1, 0.5, 0], 'LineWidth', 2); hold on;
plot(time,GrandAvgIpsiS1ERPMStd.grandAvg, 'k', 'LineWidth', 1);
% fill([time(framestart1:framestop1), fliplr(time(framestart1:framestop1))], [GrandAvgIpsiS1ERPMStd.grandAvg(framestart1:framestop1);...
%     flipud(GrandAvgIpsiS1ERPPom.grandAvg(framestart1:framestop1))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
fill([time(framestart2:framestop2), fliplr(time(framestart2:framestop2))], [GrandAvgIpsiS1ERPMStd.grandAvg(framestart2:framestop2);...
    flipud(GrandAvgIpsiS1ERPPom.grandAvg(framestart2:framestop2))], 'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-1 1]); xlim([-300 900]); xline(0); xline(200); axis ij;
title('Postomission Somatosensory ipsilateral cortex');

%% Omission : grand average graph of Omissions

file_list=dir('*_Omission_avgERPs.mat');
num_files=length(file_list);

for diri=1:num_files

    % load individual Omission average ERPs

    Omfilename = file_list(diri).name; fprintf('Processing %s\n', Omfilename);
    subject=extractBefore(Omfilename,'_Omission_avgERPs.mat');
    rootname = extractBefore(Omfilename,'Omission_avgERPs.mat');
    AllOmtrialsfilename = [rootname 'Omission_alltrialsERPs.mat'];

    % Gather all individual averages for Omission trials
    load(Omfilename);
    GrandAvgContraFrontalERPOm.(subject)=avgContraFrontalERP; GrandAvgContraS1ERPOm.(subject)=avgContraS1ERP;
    GrandAvgIpsiFrontalERPOm.(subject)=avgIpsiFrontalERP; GrandAvgIpsiS1ERPOm.(subject)=avgIpsiS1ERP;

    clear avgIpsiS1ERP avgIpsiFrontalERP avgContraS1ERP avgContraFrontalERP

end

%% calculate grand averages
GrandAvgContraFrontalERPOm.grandAvg=nanmean(GrandAvgContraFrontalERPOm{:,:},2);
GrandAvgContraS1ERPOm.grandAvg=nanmean(GrandAvgContraS1ERPOm{:,:},2);
GrandAvgIpsiFrontalERPOm.grandAvg=nanmean(GrandAvgIpsiFrontalERPOm{:,:},2);
GrandAvgIpsiS1ERPOm.grandAvg=nanmean(GrandAvgIpsiS1ERPOm{:,:},2);

%% Save Omission traces to .mat file for script 7 Omission analysis
save('GrandAvgContraFrontalERPOm.mat','GrandAvgContraFrontalERPOm');
save('GrandAvgContraS1ERPOm.mat','GrandAvgContraS1ERPOm');
save('GrandAvgIpsiFrontalERPOm.mat','GrandAvgIpsiFrontalERPOm');
save('GrandAvgIpsiS1ERPOm.mat','GrandAvgIpsiS1ERPOm');

%% Save the tables to an Excel file
writetable(GrandAvgContraFrontalERPOm, 'OmERP.xlsx', 'Sheet', 'ContraFrontal','WriteRowNames', true);
writetable(GrandAvgContraS1ERPOm, 'OmERP.xlsx', 'Sheet', 'ContraS1','WriteRowNames', true);
writetable(GrandAvgIpsiFrontalERPOm, 'OmERP.xlsx', 'Sheet', 'IpsiFrontal','WriteRowNames', true);
writetable(GrandAvgIpsiS1ERPOm, 'OmERP.xlsx', 'Sheet', 'IpsiS1','WriteRowNames', true);

%% plot grand avgs
subplot(4,4,13)
plot(time,GrandAvgContraS1ERPOm.grandAvg, 'r', 'LineWidth', 2); hold on;
fill([time(framestartOm:framestopOm), fliplr(time(framestartOm:framestopOm))], ...
     [zeros(1, length(time(framestartOm:framestopOm))), flipud(GrandAvgContraS1ERPOm.grandAvg(framestartOm:framestopOm))'], ...
     'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-0.5 0.5]); xlim([-300 900]); xline(-200,':'); xline(0,':'); xline(200,':'); axis ij;
title('Omission Somatosensory contralateral cortex');
subplot(4,4,14)
plot(time,GrandAvgContraFrontalERPOm.grandAvg, 'r', 'LineWidth', 2); hold on;
fill([time(framestartOm:framestopOm), fliplr(time(framestartOm:framestopOm))], ...
     [zeros(1, length(time(framestartOm:framestopOm))), flipud(GrandAvgContraFrontalERPOm.grandAvg(framestartOm:framestopOm))'], ...
     'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-0.5 0.5]); xlim([-300 900]); xline(-200,':'); xline(0,':'); xline(200,':'); axis ij;
title('Omission Frontal contralateral cortex');
subplot(4,4,15)
plot(time,GrandAvgIpsiFrontalERPOm.grandAvg, 'r', 'LineWidth', 2); hold on;
fill([time(framestartOm:framestopOm), fliplr(time(framestartOm:framestopOm))], ...
     [zeros(1, length(time(framestartOm:framestopOm))), flipud(GrandAvgIpsiFrontalERPOm.grandAvg(framestartOm:framestopOm))'], ...
     'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-0.5 0.5]); xlim([-300 900]); xline(-200,':'); xline(0,':'); xline(200,':'); axis ij;
title('Omission Frontal ipsilateral cortex');
subplot(4,4,16)
plot(time,GrandAvgIpsiS1ERPOm.grandAvg, 'r', 'LineWidth', 2); hold on;
fill([time(framestartOm:framestopOm), fliplr(time(framestartOm:framestopOm))], ...
     [zeros(1, length(time(framestartOm:framestopOm))), flipud(GrandAvgIpsiS1ERPOm.grandAvg(framestartOm:framestopOm))'], ...
     'k', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Time (ms)'); ylabel('Amplitude (∆µV)'); yline(0); ylim([-0.5 0.5]); xlim([-300 900]); xline(-200,':'); xline(0,':'); xline(200,':'); axis ij;
title('Omission Somatosensory ipsilateral cortex');

