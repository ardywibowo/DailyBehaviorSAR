clear; close all; clc;

%% Include Frameworks
addpath('../Frameworks/BRML');
addpath('../Helpers');
addpath('../Methods/SLDS');

import brml.*;

%% Settings and Parameters

resultName = 'Corelation';
playSound = 1;

showPlots = 0;
savePlots = 1;

numEMIterations = 400;
numStates = 3;
orderX = 1;
orderU = 1;
tSkip = 0;
imputeParamsSAR = [0.2, 0.02, 0.2, 0.02, 2, 2];

%% Import User Data
[datasetName, rangeData, numSubjects, numInputs, bmiTrainOriginal, inputTrainOriginal, bmiTest, bmiMissing, inputTest, inputMissing, time] = importDailyBehavioralSmall();

%% Analyze Input Correlation

totalTime = 0;
for i = 1 : numSubjects
	totalTime = totalTime + length(time{i});
end

allInputs = zeros(numInputs, totalTime);
for j = 1 : numInputs
	currentTime = 1;
	for i = 1 : numSubjects
		allInputs(j, currentTime : currentTime + length(time{i}) - 1) = inputTrainOriginal{i}{j};
		currentTime = currentTime + length(time{i});
	end
	allInputs(j, isnan(allInputs(j, :))) = nanmean(allInputs(j, :), 2);
end

correlations = zeros(numInputs);
for j1 = 1 : numInputs
	for j2 = 1 : numInputs
		correlations(j1, j2) = corr2(allInputs(j1, :), allInputs(j2, :));
	end
end
