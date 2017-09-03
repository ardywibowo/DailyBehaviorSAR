function [bmiBootstrap, inputBootstrap, PStGivenX1TBootstrap] = bootstrapSARData(bmiTrain, inputTrain, PStGivenX1TInit, numStates)
%BOOTSTRAPSARDATA Summary of this function goes here
%   Detailed explanation goes here

numSubjects = length(bmiTrain);
numInputs = length(inputTrain{1});

totalSamples = 0;
latestIndex = 0;
for i = 1 : numSubjects
	currentLength = length(bmiTrain{i});
	totalSamples = totalSamples + currentLength;
end

allBMI = zeros(1, totalSamples);
allStates = zeros(numStates, totalSamples);
allInputs = zeros(numInputs, totalSamples);
allCuttoffs = zeros(1, numSubjects);
for i = 1 : numSubjects
	currentLength = length(bmiTrain{i});
	allBMI(latestIndex + 1 : latestIndex + currentLength) = bmiTrain{i};
	allStates(:, latestIndex + 1 : latestIndex + currentLength) = PStGivenX1TInit{i};
	for j = 1 : numInputs
		allInputs(j, latestIndex + 1 : latestIndex + currentLength) = inputTrain{i}{j};
	end
	latestIndex = latestIndex + currentLength;
	allCuttoffs(i) = latestIndex + 1;
end

bmiBootstrap = cell(floor(totalSamples/100), 1);
PStGivenX1TBootstrap = cell(floor(totalSamples/100), 1);
inputBootstrap = cell(floor(totalSamples/100), 1);

for t = 1 : floor(totalSamples/100)
	i = randi([1 length(allBMI)]);
	if i+100 > length(allBMI)
		bootstrapIndex = i-99 : i;
	else 
		bootstrapIndex = i : i+99;
	end
	
	bmiBootstrap{t} = allBMI(bootstrapIndex);
	PStGivenX1TBootstrap{t} = allStates(:, bootstrapIndex);
	currentInput = cell(numInputs, 1);
	for j = 1 : numInputs
		currentInput{j} = allInputs(j, bootstrapIndex);
	end
	inputBootstrap{t} = currentInput;
end

end

