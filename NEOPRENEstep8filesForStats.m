%% NEOPRENE step 8 : Generating wide- and long-format data files for statistics and regression analysis
% Run from folder .xlsx files (output from the NEOPRENEstep6groupERPanalysesRSandMM.m 
% and NEOPRENEstep7omissionAnalysis.m scripts)
% This script prepares the data for analysis in R/Jamovi

close all
clear all
clc

%% SETTINGS
NROI=4; % number of ROIs
NMarkers=3; % number of markers (here : RS, Deviant MMR and PostomMMR)

%% Prepare wide-format file
wideData=table;

RS=readtable("RS.xlsx");
N=size(RS,1)-1; % number of subjects aka number of data rows in files above the grand average row
NvariablesRS=20; % number of useful variables for stats (after subject column, before the ContraFrontal_Fam_1to10 column)
NClinicalFactors=10; % number of rows to add to wide.Data before EEG data, containing clinical factors

% adding 10 Clinical factors (adjust above if changed)
wideData.filename=RS.OriginalVariableNames(1:N);
wideData.Subject=extractBetween(wideData.filename,'sub-','_');
wideData.Side = extractAfter(wideData.filename, '_');
wideData.GA=RS.GA(1:N);
wideData.Pain=RS.Pain(1:N);
wideData.logPain=log10(RS.Pain(1:N));
wideData.Sex=RS.Sex(1:N);
wideData.BRIEF=RS.BRIEF(1:N);
wideData.ASQ=RS.ASQ(1:N);
wideData.PC1_Actim=RS.PC1_Actim(1:N);

% Concatenate columns of data
wideData = [wideData RS(1:N, 2:(NvariablesRS+1))];

DevMM=readtable("DevMM.xlsx");
N=size(DevMM,1)-1; % number of subjects aka number of data rows in files above the grand average row
NvariablesDev=12; % number of useful variables for stats (after subject column, before the GA column)

DevMM = renamevars(DevMM, 'ContraFrontal_MatchedStd_peak', 'ContraFrontal_MatchedStd_peakDev');
DevMM = renamevars(DevMM, 'ContraS1_MatchedStd_peak', 'ContraS1_MatchedStd_peakDev');
DevMM = renamevars(DevMM, 'IpsiFrontal_MatchedStd_peak', 'IpsiFrontal_MatchedStd_peakDev');
DevMM = renamevars(DevMM, 'IpsiS1_MatchedStd_peak', 'IpsiS1_MatchedStd_peakDev');
wideData = [wideData DevMM(1:N, 2:(NvariablesDev+1))];

PomMM=readtable("PomMM.xlsx"); 
N=size(PomMM,1)-1; % number of subjects aka number of data rows in files above the grand average row
NvariablesPom=12; % number of useful variables for stats (after subject column, before the GA column)

PomMM = renamevars(PomMM, 'ContraFrontal_MatchedStd_peak', 'ContraFrontal_MatchedStd_peakPom');
PomMM = renamevars(PomMM, 'ContraS1_MatchedStd_peak', 'ContraS1_MatchedStd_peakPom');
PomMM = renamevars(PomMM, 'IpsiFrontal_MatchedStd_peak', 'IpsiFrontal_MatchedStd_peakPom');
PomMM = renamevars(PomMM, 'IpsiS1_MatchedStd_peak', 'IpsiS1_MatchedStd_peakPom');
wideData = [wideData PomMM(1:N, 2:(NvariablesPom+1))];

Omission=readtable("Omission.xlsx");
N=size(Omission,1); % number of subjects aka number of data rows in files above the grand average row
NvariablesOm=4; % number of useful variables for stats (after subject column, before the GA column)
wideData = [wideData Omission(1:N, 2:(NvariablesOm+1))];

writetable(wideData, 'wideData.xlsx','WriteRowNames', true);

%% Prepare long-format file

longData = stack(wideData, (NClinicalFactors+1):(size(wideData,2)), 'NewDataVariableName', 'Value', 'IndexVariableName', 'Variable');

longData.Variable=string(longData.Variable);
for j=1:length(longData.Variable)
    if contains(longData.Variable(j),'Contra'),longData.Hemisphere(j)=categorical("Contra");
    elseif contains(longData.Variable(j),'Ipsi'),longData.Hemisphere(j)=categorical("Ipsi");
    end
    if contains(longData.Variable(j),'Frontal'),longData.Region(j)=categorical("Frontal");
    elseif contains(longData.Variable(j),'S1'),longData.Region(j)=categorical("Somatosensory");
    end
    if contains(longData.Variable(j),'Fam_peak'),longData.Condition(j)=categorical("FamiliarizationPeak");
    elseif contains(longData.Variable(j),'Control_peak'),longData.Condition(j)=categorical("ControlPeak");
    elseif contains(longData.Variable(j),'Fam_latency'),longData.Condition(j)=categorical("FamiliarizationLatency");
    elseif contains(longData.Variable(j),'Control_latency'),longData.Condition(j)=categorical("ControlLatency");
    elseif contains(longData.Variable(j),'RS'),longData.Condition(j)=categorical("RS");
    elseif contains(longData.Variable(j),'Dev_peak'),longData.Condition(j)=categorical("DeviantPeak");
    elseif contains(longData.Variable(j),'MatchedStd_peakDev'),longData.Condition(j)=categorical("StdMatchedToDevPeak");
    elseif contains(longData.Variable(j),'DevMM'),longData.Condition(j)=categorical("DeviantMMR");
    elseif contains(longData.Variable(j),'Postom_peak'),longData.Condition(j)=categorical("PostomPeak");
    elseif contains(longData.Variable(j),'MatchedStd_peakPom'),longData.Condition(j)=categorical("StdMatchedToPostomPeak");
    elseif contains(longData.Variable(j),'PomMM'),longData.Condition(j)=categorical("PomMMR");
    elseif contains(longData.Variable(j),'Om_peak'),longData.Condition(j)=categorical("OmissionPeak");
    end
end

longData_sorted = sortrows(longData, {'Condition', 'Hemisphere','Region','Subject'}, {'ascend','ascend','ascend','ascend'});

writetable(longData, 'longData.xlsx');

%% Prepare long-format file of markers with respective baselines and peaks, for LMM analysis

longMarkers=table;
longMarkers.Subject=string(longData_sorted.Subject(1:N*NROI*NMarkers));
longMarkers.StimSide=string(longData_sorted.Side(1:N*NROI*NMarkers));
longMarkers.Sex=string(longData_sorted.Sex(1:N*NROI*NMarkers));
longMarkers.GA=longData_sorted.GA(1:N*NROI*NMarkers);
% longMarkers.ASQ=longData_sorted.ASQ(1:N*NROI*NMarkers);
% longMarkers.BRIEF=longData_sorted.BRIEF(1:N*NROI*NMarkers);
% longMarkers.PC1_Actim=longData_sorted.PC1_Actim(1:N*NROI*NMarkers);
longMarkers.logPain=longData_sorted.logPain(1:N*NROI*NMarkers);
longMarkers.Hemisphere=string(longData_sorted.Hemisphere(1:N*NROI*NMarkers));
longMarkers.Region=string(longData_sorted.Region(1:N*NROI*NMarkers));

longMarkers.MarkerType(1:N*NROI)=categorical("RS");
longMarkers.MarkerValue(1:N*NROI)=longData_sorted.Value(longData_sorted.Condition == "RS");
longMarkers.MarkerControl(1:N*NROI)=longData_sorted.Value(longData_sorted.Condition == "ControlPeak");
longMarkers.MarkerMeasure(1:N*NROI)=longData_sorted.Value(longData_sorted.Condition == "FamiliarizationPeak");

longMarkers.MarkerType(N*NROI+1:(N*NROI)*2)=categorical("DeviantMMR");
longMarkers.MarkerValue(N*NROI+1:(N*NROI)*2)=longData_sorted.Value(longData_sorted.Condition == "DeviantMMR");
longMarkers.MarkerControl(N*NROI+1:(N*NROI)*2)=longData_sorted.Value(longData_sorted.Condition == "StdMatchedToDevPeak");
longMarkers.MarkerMeasure(N*NROI+1:(N*NROI)*2)=longData_sorted.Value(longData_sorted.Condition == "DeviantPeak");

longMarkers.MarkerType((N*NROI)*2+1:(N*NROI)*3)=categorical("PostomMMR");
longMarkers.MarkerValue((N*NROI)*2+1:(N*NROI)*3)=longData_sorted.Value(longData_sorted.Condition == "PomMMR");
longMarkers.MarkerControl((N*NROI)*2+1:(N*NROI)*3)=longData_sorted.Value(longData_sorted.Condition == "StdMatchedToPostomPeak");
longMarkers.MarkerMeasure((N*NROI)*2+1:(N*NROI)*3)=longData_sorted.Value(longData_sorted.Condition == "PostomPeak");

writetable(longMarkers, 'longMarkers.csv', 'WriteRowNames', true);