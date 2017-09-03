clear; close all; clc;

%% Include Frameworks
addpath('../Frameworks/BRML');
addpath('../Helpers');
addpath('../Methods/SLDS');

import brml.*;

%% Settings and Parameters

resultName = 'Bootstrap Results';
playSound = 1;

numEMIterations = 400;
numBootstrap = 1000;
numStates = 3;
orderX = 1;
orderU = 1;
tSkip = 0;
imputeParamsSAR = [0.2, 0.02, 0.2, 0.02, 2, 2];

%% Import User Data
[datasetName, rangeData, numSubjects, numInputs, bmiTrain, inputTrain, bmiTest, bmiMissing, inputTest, inputMissing, time] = importDailyBehavioralSmall();

%% Create Result Folders

resultsDirectory = ['../Results/', resultName, ' - ', datasetName, ' - ', datestr(datetime('now')), '/'];
learnDirectory = [resultsDirectory 'Learning/'];
predictionDirectory = [resultsDirectory 'Prediction/'];
resultFolders = string({'Plots'});

createFolder(learnDirectory, resultFolders);
createFolder(predictionDirectory, resultFolders);


%% SAR Training

ASar = cell(numBootstrap, 1);
BjsSar = cell(numBootstrap, 1);
CSar = cell(numBootstrap, 1);
sigma2SAR = cell(numBootstrap, 1);
sTransSAR = cell(numBootstrap, 1);
pStGivenX1TsSAR = cell(numBootstrap, 1);

PStGivenX1TInit = importdata('initPStGivenX1Ts.mat');
initD = importdata('initD.mat');
for b = 1 : numBootstrap
	[bmiBootstrap, inputBootstrap, PStGivenX1TBootstrap] = bootstrapSARData(bmiTrain, inputTrain, PStGivenX1TInit, numStates);
	[~, ~, ASarTemp, BjsSarTemp, CSarTemp, sigma2SARTemp, sTransSARTemp, pStGivenX1TsSARTemp, ~, ~, ~] = ...
		inputGroupSARLearn(bmiBootstrap, inputBootstrap, orderX, orderU, numStates, tSkip, numEMIterations, imputeParamsSAR, PStGivenX1TBootstrap, initD);
	
	ASar{b} = ASarTemp;
	BjsSar{b} = BjsSarTemp;
	CSar{b} = CSarTemp;
	sigma2SAR{b} = sigma2SARTemp;
	sTransSAR{b} = sTransSARTemp;
	pStGivenX1TsSAR{b} = pStGivenX1TsSARTemp;
end

save([resultsDirectory, 'A.mat'], 'ASar');
save([resultsDirectory, 'Bjs.mat'], 'BjsSar');
save([resultsDirectory, 'C.mat'], 'CSar');
save([resultsDirectory, 'sigma2.mat'], 'sigma2SAR');
save([resultsDirectory, 'sTrans.mat'], 'sTransSAR');
save([resultsDirectory, 'pStGivenX1Ts.mat'], 'pStGivenX1TsSAR');

%% Play Finish Sound
if playSound
	load handel;
	sound(y/4,Fs);
end