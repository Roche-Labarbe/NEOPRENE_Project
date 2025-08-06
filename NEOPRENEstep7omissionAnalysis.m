%% NEOPRENE step 7 : Omission Analyses
% Run from folder containing _avgERPs.mat files (output from the NEOPRENEstep3ERPextraction.m script)
% This script calculates omission ERP values and saves them in a .xlsx file
% with corresponding clinical factors

close all
clear all
clc

%% SETTINGS

load('proc-settings.mat')

MMthreshold=MMthreshold/2; % adjust MM discarding threshold for the lower amplitudes of omission compared with ERPs

framestart=fix((baseline+ERPwindowstartOm)*samplingrate);
framestop=fix((baseline+ERPwindowstopOm)*samplingrate);

load('Clinical-variables.mat');

%% Omission activity measure

load GrandAvgContraFrontalERPOm.mat
GrandAvgContraFrontalERPOm.grandAvg=[]; % Remove the column named 'grandAvg' from the table
load GrandAvgContraS1ERPOm.mat
GrandAvgContraS1ERPOm.grandAvg=[];
load GrandAvgIpsiFrontalERPOm.mat
GrandAvgIpsiFrontalERPOm.grandAvg=[];
load GrandAvgIpsiS1ERPOm.mat
GrandAvgIpsiS1ERPOm.grandAvg=[];

OmvalueContraFrontal=[]; OmvalueContraS1=[]; OmvalueIpsiFrontal=[]; OmvalueIpsiS1=[];

for i=1:size(GrandAvgContraFrontalERPOm,2)

    array=table2array(GrandAvgContraFrontalERPOm(:,i));
    OmPeakContraFrontal=nanmean(array(framestart:framestop));
    if abs(OmPeakContraFrontal)>MMthreshold, OmPeakContraFrontal=NaN; end % Reject individual average ERPs when any value is above threshold (outlier)
    OmvalueContraFrontal=[OmvalueContraFrontal OmPeakContraFrontal];

    array=table2array(GrandAvgContraS1ERPOm(:,i));
    OmPeakContraS1=nanmean(array(framestart:framestop));
    if abs(OmPeakContraS1)>MMthreshold, OmPeakContraS1=NaN; end
    OmvalueContraS1=[OmvalueContraS1 OmPeakContraS1];

    array=table2array(GrandAvgIpsiFrontalERPOm(:,i));
    OmPeakIpsiFrontal=nanmean(array(framestart:framestop));
    if abs(OmPeakIpsiFrontal)>MMthreshold, OmPeakIpsiFrontal=NaN; end
    OmvalueIpsiFrontal=[OmvalueIpsiFrontal OmPeakIpsiFrontal];

    array=table2array(GrandAvgIpsiS1ERPOm(:,i));
    OmPeakIpsiS1=nanmean(array(framestart:framestop));
    if abs(OmPeakIpsiS1)>MMthreshold, OmPeakIpsiS1=NaN; end
    OmvalueIpsiS1=[OmvalueIpsiS1 OmPeakIpsiS1];

end

% Concatenate values in table
Omvalues=[OmvalueContraFrontal;OmvalueContraS1;OmvalueIpsiFrontal;OmvalueIpsiS1];
Omvalues=array2table(Omvalues);
Omvalues.Properties.VariableNames=GrandAvgContraFrontalERPOm.Properties.VariableNames;
Omvalues.Properties.RowNames={'ContraFrontal_Om_peak','ContraS1_Om_peak','IpsiFrontal_Om_peak','IpsiS1_Om_peak'};

% Add clinical factors
for subi=1:size(Omvalues,2)
    for factori=1:size(Factors,1)
        if contains(Omvalues.Properties.VariableNames{subi},Factors.Subject(factori))
            Omvalues{'GA',subi}=Factors.GA(factori);
            Omvalues{'Pain',subi}=Factors.Pain(factori);
            Omvalues{'SleepQ',subi}=Factors.SleepQ(factori);
            Omvalues{'ASQ',subi}=Factors.ASQ(factori);
            Omvalues{'BRIEF',subi}=Factors.BRIEF(factori);
            Omvalues{'FSPseeking',subi}=Factors.FSPseeking(factori);
            Omvalues{'FSPavoidant',subi}=Factors.FSPavoidant(factori);
            Omvalues{'FSPsensitive',subi}=Factors.FSPsensitive(factori);
            Omvalues{'FSPregistering',subi}=Factors.FSPregistering(factori);
            Omvalues{'ActiNightSleep',subi}=Factors.ActiNightSleep(factori);
            Omvalues{'ActiNapSleep',subi}=Factors.ActiNapSleep(factori);
            Omvalues{'ActiTotalSleep',subi}=Factors.ActiTotalSleep(factori);
            Omvalues{'ActiSleepEfficiency',subi}=Factors.ActiSleepEfficiency(factori);
        end
    end
end
clear subi factori diri

% Save tables for further analysis by pretty statistics software
writetable(rows2vars(Omvalues),'Omission.xlsx', 'Sheet', 'Om peak values','WriteRowNames', true);