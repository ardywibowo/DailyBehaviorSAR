clear; close all; clc;

%% Include Frameworks
addpath('../Frameworks/FDA');
addpath('../Helpers');
addpath('../Methods/FunctionalImputation');

%% Settings and Parameters

resultName = 'Imputation';
playSound = 1;

showPlots = 0;
savePlots = 1;

%% Import User Data
[datasetName, rangeData, numSubjects, numInputs, bmiTrain, inputTrain, bmiTest, bmiTestMissing, inputTest, inputTestMissing, time] = importDailyBehavioralSmall();

%% Create Data Folders

resultsDirectory = ['../Data/', datasetName, ' - ', resultName, '/'];
resultFolders = string({'Bspline/Plots', 'Haar/Plots', 'PACE/Plots', 'mean/Plots', 'previous/Plots'});

createFolder(resultsDirectory, resultFolders);

%% Perform Imputation
imputedBMITrain = cell(size(bmiTrain));
imputedInputTrain = cell(size(inputTrain));

methodType = 'previous';

for i = 1 : numSubjects
	disp(i);
	imputedBMITrain{i} = functionalImpute(bmiTrain{i}, bmiTrain{i}, time{i}, methodType);
	
	UiImputed = cell(numInputs, 1);
	for j = 1 : numInputs
		UiImputed{j} = functionalImpute(inputTrain{i}{j}, inputTrain{i}{j}, time{i}, methodType);
	end
	imputedInputTrain{i} = UiImputed;
	
	if showPlots
		figure;
	else
		figure('visible', 'off');
	end
	
	hold on;
	plot(imputedBMITrain{i})
	scatter(1:length(bmiTrain{i}), bmiTrain{i});
	
	if savePlots
		saveas(gcf, [resultsDirectory, methodType, '/Plots/Subject' num2str(i) '.fig']);
		saveas(gcf, [resultsDirectory, methodType, '/Plots/Subject' num2str(i) '.png']);
		close;
	end
end

save([resultsDirectory, methodType, '/', 'imputedBMI.mat'], 'imputedBMITrain');
save([resultsDirectory, methodType, '/', 'imputedInput.mat'], 'imputedInputTrain');

%% Play Finish Sound
if playSound
	load handel;
	sound(y/4,Fs);
end