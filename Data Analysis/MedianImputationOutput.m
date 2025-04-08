clear; close all; clc;

n = 56;
possFreq = 5;

%search for the excel file, add to path
[file, path] = uigetfile('*.xls;*.xlsx', 'Select the Excel File');
filename = fullfile(path, file);

if file == 0
    error('No file selected. Please select a valid Excel file.');
end

%%

% %Pull data out of both sheets in file
RawDat_Bel = readmatrix(filename,'Sheet','Beliefs');
RawDat_Beh = readmatrix(filename,'Sheet', 'Behaviors');

DatFlip_Bel = rot90(RawDat_Bel);
DatFlip_Beh = rot90(RawDat_Beh);

% %Perform median across each criterion
MedArray_Bel = median(DatFlip_Bel, 1, "omitnan");
MedArray_Beh = median(DatFlip_Beh, 1, "omitnan");

% %Back fill median value in for median imputation
IsNan_Bel = isnan(DatFlip_Bel);
DatFlip_Bel(IsNan_Bel) = repelem(MedArray_Bel,sum(IsNan_Bel,1));
IsNan_Beh = isnan(DatFlip_Beh);
DatFlip_Beh(IsNan_Beh) = repelem(MedArray_Beh,sum(IsNan_Beh,1));

ImpDat_Bel = rot90(DatFlip_Bel, -3);
ImpDat_Beh = rot90(DatFlip_Beh, -3);

% %Set up for Ordinal Ranking Data
criteria = ["Leadership", "Relationships", "Production", "Spending", "Safety", "Time"];

%Sorts the data from smallest to largest
[SortedMedArray_Bel, sortIdx_Bel] = sort(MedArray_Bel,'descend');
SortedLabels_Bel = criteria(sortIdx_Bel); 
[SortedMedArray_Beh, sortIdx_Beh] = sort(MedArray_Beh,'descend');
SortedLabels_Beh = criteria(sortIdx_Beh); 

% %disp('Sorted Median Values (Beliefs):');
% %disp(table(SortedMedArray_Bel, SortedLabels_Bel, 'VariableNames',{'Median Value','Criterion'}));

% %disp('Sorted Median Values (Behaviors):');
% %disp(table(SortedMedArray_Beh, SortedLabels_Beh, 'VariableNames',{'Median Value','Criterion'}));



%%

RawDat_BelImp = readmatrix(filename,'Sheet','Beliefs_Imp');
RawDat_BehImp = readmatrix(filename,'Sheet', 'Behaviors_Imp');

MedArray_BelImp = median(RawDat_BelImp, 1, "omitnan");
MedArray_BehImp = median(RawDat_BehImp, 1, "omitnan");

IsNan_BelImp = isnan(RawDat_BelImp);
RawDat_BelImp(IsNan_BelImp) = repelem(MedArray_BelImp,sum(IsNan_BelImp,1));
IsNan_BehImp = isnan(RawDat_BehImp);
RawDat_BehImp(IsNan_BehImp) = repelem(MedArray_BehImp,sum(IsNan_BehImp,1));

%disp(RawDat_BelImp);
%disp(RawDat_BehImp)

sumAllColumns_Bel = sum(RawDat_BelImp);
%disp(sumAllColumns_Bel);
AdjSum_Bel = sumAllColumns_Bel - MedArray_BelImp;
%disp(AdjSum_Bel);
sumAllColumns_Beh = sum(RawDat_BehImp);
%disp(sumAllColumns_Bel);
AdjSum_Beh = sumAllColumns_Beh - MedArray_BehImp;
%disp(AdjSum_Bel);

ImpFreq_Bel = (AdjSum_Bel/(n*possFreq))*100;
ImpFreq_Beh = (AdjSum_Beh/(n*possFreq))*100;
%disp(ImpFreq_Bel);
%disp(ImpFreq_Beh);


disp(table(SortedLabels_Bel', SortedMedArray_Bel', sortIdx_Bel', 'VariableNames', {'Criterion', 'MedianValue', 'SortIndex'}));
disp(table(SortedLabels_Beh', SortedMedArray_Beh', sortIdx_Beh', 'VariableNames', {'Criterion', 'MedianValue', 'SortIndex'}));


%%

figure;

% Define color mapping
criteria_colors = struct( ...
    'Leadership', [0.9290, 0.6940, 0.1250], ...         % Yellow
    'Relationships', [0.4940, 0.1840, 0.5560], ...      % Purple
    'Production', [0.6350, 0.0780, 0.1840], ...         % Red
    'Spending', [0.4660, 0.6740, 0.1880], ...           % Green
    'Safety', [0.8500, 0.3250, 0.0980], ...             % Orange
    'Time', [0, 0.4470, 0.7410] ...                     % Blue
);

% X-axis labels
xBel = ones(1, length(SortedMedArray_Bel));  % "Beliefs" at x = 1
xBeh = ones(1, length(SortedMedArray_Beh)) * 2;  % "Behaviors" at x = 2

hold on;
legend_handles = gobjects(1, length(criteria));  % Initialize legend handles
added_criteria = {};  % Track criteria added to the legend

% Step 1: Plot scatter points and connecting lines
for i = 1:length(SortedLabels_Bel)
    % Get the correct criterion name
    criterion_name = SortedLabels_Bel(i);

    % Ensure the criterion exists in the color map
    if isfield(criteria_colors, criterion_name)
        color = criteria_colors.(criterion_name);
    else
        color = [0, 0, 0];  % Default to black if not found
    end

    % Find y-coordinates for correct ranking
    y_bel = find(SortedLabels_Bel == criterion_name);
    y_beh = find(SortedLabels_Beh == criterion_name);

    % Plot scatter points
    scatter(xBel(i), y_bel, 100, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
    scatter(xBeh(i), y_beh, 100, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');

    % Draw lines connecting beliefs and behaviors
    plot([xBel(i), xBeh(i)], [y_bel, y_beh], '-', 'Color', color, 'LineWidth', 2);

    % Add to legend only if not already added
    if ~ismember(criterion_name, added_criteria)
        legend_handles(length(added_criteria) + 1) = scatter(nan, nan, 100, ...
            'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');  % Dummy scatter for legend
        added_criteria = [added_criteria, criterion_name];
    end
end

% Step 2: Clean up empty placeholders
valid_legend_handles = legend_handles(legend_handles ~= 0);

% Customize plot
set(gca, 'YLim', [0.5, 6.5]);  
set(gca, 'YTick', 1:6);  
set(gca, 'YDir', 'reverse');  % Reverse the y-axis
set(gca, 'XTick', [1, 2]);  
set(gca, 'XTickLabel', {'Espoused Beliefs', 'Simulated Behaviors'});
xlabel('Phase');
ylabel('Ordinal Ranking');
title('Ordinal Ranking Comparison: Espoused Beliefs vs. Simulated Behaviors in Public Welfare Context');

% Step 3: Assign correct legend
legend(valid_legend_handles, added_criteria, 'Location', 'best', 'TextColor', 'black');

grid on;
xtickangle(45);
hold off;
