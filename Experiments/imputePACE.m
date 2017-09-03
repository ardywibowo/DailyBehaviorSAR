clear; close all; clc;

%% Include Frameworks
addpath('../Frameworks/PACE');
addpath('../Helpers');
addpath('../Methods/FunctionalImputation');

%% Settings and Parameters

resultName = 'Imputation';
playSound = 1;

paceOptions = setOptions('selection_k', 8, 'maxk', 10, 'ngrid', 75, 'ngrid1', ...
    55, 'numBins', 0, 'ntest1', 55);


%% Import User Data
[datasetName, rangeData, numSubjects, numInputs, bmiTrain, inputTrain, bmiTest, bmiTestMissing, inputTest, inputTestMissing, time] = importDailyBehavioralSmall();

%% Create Data Folders

resultsDirectory = ['../Data/', datasetName, ' - ', resultName, '/'];
resultFolders = string({'Bspline/Plots', 'Haar/Plots', 'PACE/Plots'});

createFolder(resultsDirectory, resultFolders);

%% Perform Imputation
imputedBMITrain = cell(size(bmiTrain));
imputedInputTrain = cell(size(inputTrain));

methodType = 'pace';

Y = cell(1, numSubjects);
T = cell(1, numSubjects);
for i = 1 : numSubjects
	Y{i} = bmiTrain{i}(~isnan(bmiTrain{i}));
	T{i} = time{i}(~isnan(bmiTrain{i}));
end

for i = 1 : numSubjects
	disp(i);
	imputedBMITrain{i} = paceImpute(Y, T, time{i}, i, paceOptions);
	figure('visible', 'off');
	
	hold on;
	plot(imputedBMITrain{i})
	scatter(1:length(bmiTrain{i}), bmiTrain{i});
	
	saveFigure([resultsDirectory, methodType, '/Plots/Subject' num2str(i)]);
end

Y = cell(1, numSubjects);
T = cell(1, numSubjects);
UjsImputed = cell(numSubjects, numInputs);
for j = 1 : numInputs
	disp(j);
	for i = 1 : numSubjects
		Y{i} = inputTrain{i}{j}(~isnan(inputTrain{i}{j}));
		T{i} = time{i}(~isnan(inputTrain{i}{j}));
	end
	
	for i = 1 : numSubjects
		UjsImputed{i, j} = paceImpute(Y, T, time{i}, i, paceOptions);
	end
end

for i = 1 : numSubjects
	UiImputed = cell(numInputs, 1);
	for j = 1 : numInputs
		UiImputed{j} = UjsImputed{i, j};
	end
	imputedInputTrain{i} = UiImputed;
end

save([resultsDirectory, methodType, '/', 'imputedBMI.mat'], 'imputedBMITrain');
save([resultsDirectory, methodType, '/', 'imputedInput.mat'], 'imputedInputTrain');

%% Play Finish Sound
if playSound
	load handel
	sound(y/4,Fs)
end