clear; close all; clc;

%% Include Frameworks
addpath('../Methods/SSMO');

import brml.*;

%% Settings and Parameters

resultName = 'TestSSMO';
playSound = 1;

numIter = 1;
imputeParamsSSMO = [0.2, 0.02, 0.2, 0.02, 2, 2];

%% Import User Data
[datasetName, rangeData, numSubjects, numInputs, bmiTrain, inputTrain, bmiTest, nanMask, inputTest, time] = importDailyBehavioralSmall();

%% Create Result Folders

resultsDirectory = ['../Results/', resultName, ' - ', datasetName, ' - ', datestr(datetime('now')), '/'];
learnDirectory = [resultsDirectory 'Learning/'];
predictionDirectory = [resultsDirectory 'Prediction/'];
resultFolders = string({'Plots'});

createFolder(learnDirectory, resultFolders);
createFolder(predictionDirectory, resultFolders);

%% SSMO Training

bmiImputedSSMO = cell(size(bmiTrain));
UisImputedSSMO = cell(size(inputTrain));

ASsmo = cell(numSubjects, 1);
BjsSsmo = cell(numSubjects, 1);
CSsmo = cell(numSubjects, 1);
for i = 1 : numSubjects
	disp(i);
	[bmiImputedSSMO{i}, UisImputedSSMO{i}, ASsmo{i}, BjsSsmo{i}, CSsmo{i}] = SSMOTrain(bmiTrain{i}, inputTrain{i}, imputeParamsSSMO, numIter);
end

save([resultsDirectory, 'bmiImputedSSMO.mat'], 'bmiImputedSSMO');
save([resultsDirectory, 'UisImputedSSMO.mat'], 'UisImputedSSMO');
save([resultsDirectory, 'ASsmo.mat'], 'ASsmo');
save([resultsDirectory, 'BjsSsmo.mat'], 'BjsSsmo');
save([resultsDirectory, 'CSsmo.mat'], 'CSsmo');

% Update Testing Data with Imputed Values
bmiTestSSMO = bmiTest;
bmiTestMissing = nanMask;
inputTestSSMO = inputTest;
for i = 1 : numSubjects
	bmiTestSSMO{i} = [bmiImputedSSMO{i}', bmiTestSSMO{i}];
	bmiTestMissing{i} = [bmiImputedSSMO{i}', nanMask{i}];
	for j = 1 : numInputs
		inputTestSSMO{i}{j} = [UisImputedSSMO{i}{j}(:)', inputTestSSMO{i}{j}];
	end
end

%% Plot Inference

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
	
	BMIMapped = mapRange(bmiImputedSSMO{i}, rangeData);
	plot(BMIMapped, 'r', 'LineWidth', 1);
	legendInfo{legendIndex} = 'SSMO Imputed'; %#ok
	legendIndex = legendIndex + 1;	
	legend(legendInfo);
	
	saveFigure([learnDirectory 'Plots/Subject' num2str(i)]);
end

%% SSMO Prediction

bmiSSMOPredicted = cell(numSubjects, 1);
for i = 1 : numSubjects
	bmiSSMOPredicted{i} = SSMOPredict(bmiTestSSMO{i}, bmiTestMissing{i}, inputTestSSMO{i}, ASsmo{i}, BjsSsmo{i}, CSsmo{i});
end
save([predictionDirectory, 'bmiSSMOPredicted.mat'], 'bmiSSMOPredicted');

%% Plot Prediction and Evaluation

% Errors: Absolute and RMSE respectively
errorsSSMO = zeros(2, numSubjects);

% Get original Test BMI
for i = 1 : numSubjects
	bmiTest{i} = [bmiTrain{i} nanMask{i}];
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
	
	BMIPredictedMapped = mapRange(bmiSSMOPredicted{i}, rangeData);
	plot(BMIPredictedMapped, 'g', 'LineWidth', 1);
	legendInfo{legendIndex} = 'SSMO';
	legendIndex = legendIndex + 1;
	legend(legendInfo);
	
	saveFigure([predictionDirectory 'Plots/Subject' num2str(i)]);

	mappedTest = mapRange(bmiTestSSMO{i}, rangeData);
	mappedSSMO = mapRange(bmiSSMOPredicted{i}, rangeData);
	difference = mappedTest(~isnan(nanMask{i})) - mappedSSMO(~isnan(nanMask{i}));

	% Absolute Error
	errorsSSMO(1, i) = mean(abs(difference)); 
	% RMSE
	errorsSSMO(2, i) = sqrt(var(difference));
end

save([resultsDirectory 'errorsSSMO.mat'], 'errorsSSMO');
[meanError, stdError] = overallError(errorsSSMO);

%% Play Finish Sound
if playSound
	load handel;
	sound(y/4,Fs);
end