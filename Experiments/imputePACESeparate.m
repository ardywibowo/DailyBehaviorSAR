clear; close all; clc;

%% Include Frameworks
addpath('../Frameworks/PACE');
addpath('../Helpers');
addpath('../Methods/FunctionalImputation');

%% Settings and Parameters

resultName = 'Imputation';
playSound = 1;

paceOptions = setOptions('selection_k', 4, 'maxk', 5, 'ngrid', 51, 'ngrid1', ...
    30, 'numBins', 0, 'ntest1', 30);


%% Import User Data
[datasetName, rangeData, numSubjects, numInputs, bmiTrain, inputTrain, bmiTest, bmiTestMissing, inputTest, inputTestMissing, time] = importDailyBehavioralSmall();

%% Create Data Folders

resultsDirectory = ['../Data/', datasetName, ' - ', resultName, '/'];
resultFolders = string({'Bspline/Plots', 'Haar/Plots', 'pace/Plots', 'pace-separate/Plots'});

createFolder(resultsDirectory, resultFolders);

%% Perform Imputation
imputedBMITrain = cell(size(bmiTrain));
imputedInputTrain = cell(size(inputTrain));

methodType = 'pace';
methodName = 'pace-separate';

for i = 1 : numSubjects
	disp(i);
	Y = bmiTrain{i}(~isnan(bmiTrain{i}));
	T = time{i}(~isnan(bmiTrain{i}));
	imputedBMITrain{i} = paceImpute(cell({Y}), cell({T}), time{i}, 1, paceOptions);
	
	figure('visible', 'off');
	hold on; box on;
	plot(imputedBMITrain{i})
	scatter(1:length(bmiTrain{i}), bmiTrain{i});
	
	saveFigure([resultsDirectory, methodName, '/Plots/Subject' num2str(i)]);
end

UjsImputed = cell(numSubjects, numInputs);
for j = 1 : numInputs
	disp(j);
	for i = 1 : numSubjects
		Y = inputTrain{i}{j}(~isnan(inputTrain{i}{j}));
		T = time{i}(~isnan(inputTrain{i}{j}));
		UjsImputed{i, j} = paceImpute(cell({Y}), cell({T}), time{i}, 1, paceOptions);
	end
end

for i = 1 : numSubjects
	UiImputed = cell(numInputs, 1);
	for j = 1 : numInputs
		UiImputed{j} = UjsImputed{i, j};
	end
	imputedInputTrain{i} = UiImputed;
end

save([resultsDirectory, methodName, '/', 'imputedBMI.mat'], 'imputedBMITrain');
save([resultsDirectory, methodName, '/', 'imputedInput.mat'], 'imputedInputTrain');

%% Play Finish Sound
if playSound
	load handel
	sound(y/4,Fs)
end