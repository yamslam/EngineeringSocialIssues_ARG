%%
clear all; close all; clc;

%search for the excel file, add to path
[file, path] = uigetfile('*.xls;*.xlsx', 'Select the Excel File');
filename = fullfile(path, file);

if file == 0
    error('No file selected. Please select a valid Excel file.');
end
%% 

%Pull data out of both sheets in file
RawDat_Bel = readmatrix(filename,'Sheet','Beliefs');
RawDat_Beh = readmatrix(filename,'Sheet', 'Behaviors');

DatFlip_Bel = rot90(RawDat_Bel);
DatFlip_Beh = rot90(RawDat_Beh);

%Perform median across each criterion
MedArray_Bel = median(DatFlip_Bel, 1, "omitnan");
MedArray_Beh = median(DatFlip_Beh, 1, "omitnan");

%Back fill median value in for median imputation
IsNan_Bel = isnan(DatFlip_Bel);
DatFlip_Bel(IsNan_Bel) = repelem(MedArray_Bel,sum(IsNan_Bel,1));
IsNan_Beh = isnan(DatFlip_Beh);
DatFlip_Beh(IsNan_Beh) = repelem(MedArray_Beh,sum(IsNan_Beh,1));

ImpDat_Bel = rot90(DatFlip_Bel, -3);
ImpDat_Beh = rot90(DatFlip_Beh, -3);

%Set up for Ordinal Ranking Data
criteria = ["Leadership", "Relationships", "Production", "Spending", "Safety", "Time"];

%Sorts the data from smallest to largest
[SortedMedArray_Bel, sortIdx_Bel] = sort(MedArray_Bel,'descend');
SortedLabels_Bel = criteria(sortIdx_Bel); 
[SortedMedArray_Beh, sortIdx_Beh] = sort(MedArray_Beh,'descend');
SortedLabels_Beh = criteria(sortIdx_Beh); 

%Display in Command Window to confirm math is mathing
%disp('Sorted Median Values (Beliefs):');
%disp(table(SortedMedArray_Bel, SortedLabels_Bel, 'VariableNames',{'Median Value','Criterion'}));

%disp('Sorted Median Values (Behaviors):');
%disp(table(SortedMedArray_Beh, SortedLabels_Beh, 'VariableNames',{'Median Value','Criterion'}));

%%

RawDat_BelImp = readmatrix(filename,'Sheet','Beliefs_Imp');
RawDat_BehImp = readmatrix(filename,'Sheet', 'Behaviors_Imp');

MedArray_BelImp = median(RawDat_BelImp, 1, "omitnan");
MedArray_BehImp = median(RawDat_BehImp, 1, "omitnan");

IsNan_BelImp = isnan(RawDat_BelImp);
RawDat_BelImp(IsNan_BelImp) = repelem(MedArray_BelImp,sum(IsNan_BelImp,1));
IsNan_BehImp = isnan(RawDat_BehImp);
RawDatBehImp(IsNan_BehImp) = repelem(MedArray_BehImp,sum(IsNan_BehImp,1));

disp(RawDat_BelImp);
disp(RawDatBehImp)

% Compute Row-Wise Sum and Frequency Estimates
rowSums_Bel = sum(ImpDat_Bel, 2);  % Sum across rows
freqEstimates_Bel = rowSums_Bel / 280;  % Divide by 280

rowSums_Beh = sum(ImpDat_Beh, 2);  % Sum across rows
freqEstimates_Beh = rowSums_Beh / 280;  % Divide by 280

% Display Results
%disp('Beliefs: Row Sum and Estimated Frequency:');
%disp(table(criteria', rowSums_Bel, freqEstimates_Bel, 'VariableNames', {'Category', 'RowSum', 'EstimatedFrequency'}));

%disp('Behaviors: Row Sum and Estimated Frequency:');
%disp(table(criteria', rowSums_Beh, freqEstimates_Beh, 'VariableNames', {'Category', 'RowSum', 'EstimatedFrequency'}));

%figure;

