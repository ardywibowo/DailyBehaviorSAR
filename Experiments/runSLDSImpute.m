clear; close all; clc;

%% Include Frameworks
addpath('../Frameworks/BRML');
addpath('../Helpers');
addpath('../Methods/SLDS');

import brml.*;

%% Settings and Parameters

resultName = 'SLDS - Previous';
playSound = 1;

numEMIterations = 400;
numStates = 3;
orderX = 1;
orderU = 1;
tSkip = 0;
imputeParamsSAR = [0.2, 0.02, 0.2, 0.02, 2, 2];

%% Import User Data
[datasetName, rangeData, numSubjects, numInputs, bmiTrainOriginal, inputTrainOriginal, bmiTest, bmiMissing, inputTest, inputMissing, time] = importDailyBehavioralSmall();

imputeMethod = 'previous';
imputeDirectory = ['../Data/DailyBehavioral_small - Imputation/' imputeMethod];
bmiTrain = importdata([imputeDirectory '/' 'imputedBMI.mat']);
inputTrain = importdata([imputeDirectory '/' 'imputedInput.mat']);

%% Create Result Folders

resultsDirectory = ['../Results/', resultName, ' - ', datasetName, ' - ', datestr(datetime('now')), '/'];
learnDirectory = [resultsDirectory 'Learning/'];
predictionDirectory = [resultsDirectory 'Prediction/'];
resultFolders = string({'Plots'});

createFolder(learnDirectory, resultFolders);
createFolder(predictionDirectory, resultFolders);


%% SAR Training

[bmiImputedSAR, UisImputedSAR, ASar, BjsSar, CSar, sigma2SAR, sTransSAR, pStGivenX1TsSAR, logLikelihoodsSAR] = inputGroupSARLearn(bmiTrain, inputTrain, orderX, orderU, numStates, tSkip, numEMIterations, imputeParamsSAR);
save([resultsDirectory, 'A.mat'], 'ASar');
save([resultsDirectory, 'Bjs.mat'], 'BjsSar');
save([resultsDirectory, 'C.mat'], 'CSar');

save([resultsDirectory, 'bmi.mat'], 'bmiImputedSAR');
save([resultsDirectory, 'input.mat'], 'UisImputedSAR');
save([resultsDirectory, 'sigma2.mat'], 'sigma2SAR');
save([resultsDirectory, 'sTrans.mat'], 'sTransSAR');
save([resultsDirectory, 'pStGivenX1Ts.mat'], 'pStGivenX1TsSAR');
save([resultsDirectory, 'logLikelihood.mat'], 'logLikelihoodsSAR');

% Update Testing Data with Imputed Values
bmiTestSAR = bmiTest;
bmiTestMissing = bmiMissing;
inputTestSAR = inputTest;
for i = 1 : numSubjects
	bmiTestSAR{i} = [bmiImputedSAR{i}, bmiTestSAR{i}];
	bmiTestMissing{i} = [bmiImputedSAR{i}, bmiMissing{i}];
	for j = 1 : numInputs
		inputTestSAR{i}{j} = [UisImputedSAR{i}{j}(:)', inputTestSAR{i}{j}];
	end
end

%% Plot Inference

stateColors = hsv(numStates);

Shats = cell(numSubjects, 1);
for i = 1 : numSubjects
	figure('visible', 'off');
	hold on; box on;
	title('Learned States and Imputation Results');
	xlabel('Time (Days)'), ylabel('BMI');
	legendIndex = 1;

	originalMapped = mapRange(bmiTrain{i}, rangeData);
	scatter(1 : length(originalMapped), originalMapped, 'filled', 'MarkerFaceColor', 'm');
	legendInfo{legendIndex} = 'Original'; %#ok
	legendIndex = legendIndex + 1;

	[~, Shats{i}] = max(pStGivenX1TsSAR{i}, [], 1); % find the most likely MPM switches

	BMIMapped = mapRange(bmiImputedSAR{i}, rangeData);
	plot(BMIMapped, 'k', 'LineWidth', 1);
	legendInfo{legendIndex} = 'SAR SSMO Imputed'; %#ok
	legendIndex = legendIndex + 1;
	
	for s = 1 : numStates
		tt = find(Shats{i} == s);
		plot(tt, BMIMapped(tt), '.', 'color', stateColors(s,:), 'MarkerSize', 10);
	end
	
	legend(legendInfo);
	saveFigure([learnDirectory 'Plots/Subject' num2str(i)]);
end

%% SAR Prediction

sPriors = cell(numSubjects, 1);
bmiSARPredicted = cell(numSubjects, 1);
SEstimates = cell(numSubjects, 1);

for i = 1 : numSubjects
	disp(i);
	sPriors{i} = condp(ones(numStates, 1)); % Switch prior
	[bmiSARPredicted{i}, SEstimates{i}] = inputSARPredict(bmiTestSAR{i}, bmiTestMissing{i}, inputTestSAR{i}, ASar, BjsSar, CSar, sPriors{i}, sTransSAR{i}, sigma2SAR{i}, tSkip);
end
save([predictionDirectory, 'bmiSARPredicted.mat'], 'bmiSARPredicted');
save([predictionDirectory, 'SEstimates.mat'], 'SEstimates');

%% Plot Prediction and Evaluation

% Errors: Absolute and RMSE respectively
errorsSAR = zeros(2, numSubjects);

% Get original Test BMI
for i = 1 : numSubjects
	bmiTest{i} = [bmiTrainOriginal{i} bmiMissing{i}];
end

% Plot True and Predicted BMI
for i = 1 : numSubjects
	figure('visible', 'off');
	hold on; box on;
	title('BMI Prediction');
	xlabel('Time (Days)'), ylabel('BMI');
	legendIndex = 1;

	BMITestMapped = mapRange(bmiTest{i}, rangeData);
	plot(BMITestMapped, 'm', 'LineWidth', 1);
	legendInfo{legendIndex} = 'True Observation';
	legendIndex = legendIndex + 1;

	BMIPredictedMapped = mapRange(bmiSARPredicted{i}, rangeData);
	plot(BMIPredictedMapped, 'k', 'LineWidth', 1);
	legendInfo{legendIndex} = 'SAR';
	legendIndex = legendIndex + 1;

	for s = 1 : numStates
		tState = find(SEstimates{i} == s);
		plot(tState, BMIPredictedMapped(tState), '.', 'color', stateColors(s, :), 'markersize', 10);
	end
	legend(legendInfo);

	saveFigure([predictionDirectory 'Plots/Subject' num2str(i)]);

	mappedTest = mapRange(bmiTestSAR{i}, rangeData);
	mappedSAR = mapRange(bmiSARPredicted{i}, rangeData);
	difference = mappedTest(~isnan(bmiMissing{i})) - mappedSAR(~isnan(bmiMissing{i}));

	% Absolute Error
	errorsSAR(1, i) = mean(abs(difference)); 
	% RMSE
	errorsSAR(2, i) = sqrt(var(difference));
end

save([resultsDirectory 'errorsSAR.mat'], 'errorsSAR');
[meanError, stdError] = overallError(errorsSAR);

figure('visible', 'off');
hold on; box on;
plot(logLikelihoodsSAR);

saveFigure([resultsDirectory 'Likelihood' num2str(i)]);

%% Play Finish Sound
if playSound
	load handel;
	sound(y/4,Fs);
end