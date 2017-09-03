function [datasetName, rangeData, numSubjects, numInputs, bmiTrain, inputTrain, bmiTest, bmiTestMissing, inputTest, inputTestMissing, time] = importDailyBehavioralSmall()
%IMPORTDAILYBEHAVIORALSMALL Summary of this function goes here
%   Detailed explanation goes here

%% Data Folders and Directories
datasetName = 'DailyBehavioral_small';
dataDirectory = ['../Data/', datasetName, '/'];

trainFolder = [dataDirectory, 'Users/Train'];
testFolder = [dataDirectory, 'Users/Test'];
varColumns = [3 4 5 6];
numInputs = length(varColumns);

rangeData = importdata([dataDirectory, 'range_bmi.mat']);

trainDirectory = dir([trainFolder, '/*.mat']);
testDirectory = dir([testFolder, '/*.mat']);

numSubjects = length(trainDirectory(not([trainDirectory.isdir])));

%% Import User Data
bmiTrain = cell(numSubjects, 1);
bmiTest = cell(numSubjects, 1);
bmiTestMissing = cell(numSubjects, 1);

inputTrain = cell(numSubjects, 1);
inputTest = cell(numSubjects, 1);
inputTestMissing = cell(numSubjects, 1);
time = cell(numSubjects, 1);

for i = 1 : numSubjects
	trainFileName = trainDirectory(i).name;
	testFileName = testDirectory(i).name;

	userTrain = importdata([trainFolder '/' trainFileName]);
	userTest = importdata([testFolder '/' testFileName]);

	bmiTrain{i} = userTrain(:, end)';
	bmiTest{i} = userTest(:, end)';
	bmiTestMissing{i} = bmiTest{i};
	bmiTest{i}(isnan(bmiTest{i})) = nanmean([userTrain(:, end)', userTest(:, end)']);

	time{i} = userTrain(:, 1)';

	Uis = cell(numInputs, 1);
	UiTests = cell(numInputs, 1);
	UiMissing = cell(numInputs, 1);
	for j = 1 : numInputs
		Uis{j} = userTrain(:, varColumns(j))';

		Uij = userTest(:, varColumns(j))';
		UiMissing{j} = Uij;
		Uij(isnan(Uij)) = nanmean([userTrain(:, varColumns(j))', userTest(:, varColumns(j))']);
		UiTests{j} = Uij;
	end

	inputTrain{i} = Uis;
	inputTest{i} = UiTests;
	inputTestMissing{i} = UiMissing;
end

end

