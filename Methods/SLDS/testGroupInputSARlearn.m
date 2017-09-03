clear; close all; clc;

tic;

addpath('../../BRMLtoolkit/');
import brml.*;

%% Parameters
S = 3;     % Number of Hidden states
L = 3;     % Order of each AR model
T = 200;   % Length of the time-series
Tskip = 0; % Time between possible switches

numVars = 1;
numUsers = 1;
numMissing = 0;

%% Create Test Data
sTrue = zeros(1, T);
ATrue = 0.1*randn(L, S);
CTrue = 0.1*randn(1, S);
BjsTrue = cell(numVars, 1);
for j = 1 : numVars
	BjsTrue{j} = 0.1*randn(L, S);
end

Xis = cell(numUsers, 1);
Uis = cell(numUsers, 1);
sigmaTrue = cell(numUsers, 1);
for i = 1 : numUsers
	sigmaTrue{i} = randn(1, S);
	Xis{i} = zeros(1, T);
	
	for j = 1 : numVars
		Uis{i}{j} = zeros(1, T);
		Uis{i}{j}(1) = randn;
	end
	
	currentS = randi([1 S]);
	sTrue(1) = currentS;
	Xis{i}(1) = randn + sigmaTrue{i}(currentS);
	for t = 2 : T
		if mod(t, Tskip) == 0 || Tskip == 0
			currentS = randi([1 S]);
		end
		UiPred = cell(numVars, 1);
		for j = 1 : numVars
			UiPred{j} = Uis{i}{j}(1:t);
		end
		Xpred = sarMean(Xis{i}(1:t), UiPred, t, ATrue, BjsTrue, CTrue);
		Xis{i}(t) = Xpred(currentS) + sigmaTrue{i}(currentS);
		for j = 1 : numVars
			Uis{i}{j}(t) = randn;
		end
		sTrue(t) = currentS;
	end
end

%% Divide Training Data
XisTrain = cell(size(Xis));
UisTrain = cell(size(Uis));
trainingLength = floor(T/2);
for i = 1 : numUsers
	XisTrain{i} = Xis{i}(1 : trainingLength);
	for j = 1 : numVars
		UisTrain{i}{j} = Uis{i}{j}(1 : trainingLength);
	end
end

%% Perform Inference
numIterations = 30;
[XisImputed, UisImputed, A, Bjs, C, sigma2, sTrans, pStGivenX1Ts, logLikelihood] = inputGroupSARLearn(XisTrain, UisTrain, L, L, S, Tskip, numIterations);

% Plot True States
stateColors = hsv(S);
for i = 1 : length(Xis)
	figure(i);
	subplot(2, 1, 1); 
	plot(Xis{i}(1 : trainingLength), 'k');
	hold on;
	title('Sample Switches');
	
	for s = 1 : S
		tState = find(sTrue(1 : trainingLength) == s);
		plot(tState, Xis{i}(tState), '.', 'color', stateColors(s,:), 'markersize', 10);
	end
end

Shats = cell(size(Xis));
% Plot Learned States
for i = 1 : length(XisImputed)
	[~, Shats{i}] = max(pStGivenX1Ts{i}, [], 1); % Find the most likely MPM switches

	figure(i);
	subplot(2, 1, 2); 
	plot(XisImputed{i}, 'k'); 
	hold on; 
	title('Learned Switches');
	
	for s = 1 : S
		tState = find(Shats{i} == s);
		plot(tState, XisImputed{i}(tState), '.', 'color', stateColors(s, :), 'markersize', 10);
	end	
end

toc;

%% Perform Prediction
sPriors = cell(size(Xis));
XisPredicted = cell(size(Xis));
SEstimates = cell(size(Xis));
numPred = 50; % T - trainingLength

for i = 1 : numUsers
	sPriors{i} = condp(ones(S, 1)); % switch prior
	[XisPredicted{i}, SEstimates{i}] = inputSARPredict(XisImputed{i}, Uis{i}, A, Bjs, C, sPriors{i}, sTrans{i}, sigma2{i}, Tskip, numPred, numIterations);
end

% Plot True States
fullLength = trainingLength + numPred;
for i = 1 : numUsers
	figure(i + numUsers);
	subplot(2, 1, 1); 
	plot(Xis{i}(1 : fullLength), 'k');
	hold on;
	title('True Switches');
	
	for s = 1 : S
		tState = find(sTrue(1 : fullLength) == s);
		plot(tState, Xis{i}(tState), '.', 'color', stateColors(s,:), 'markersize', 10);
	end
end

% Plot Learned States
for i = 1 : numUsers
	Shats{i} = [Shats{i}, SEstimates{i}];

	figure(i + numUsers);
	subplot(2, 1, 2); 
	plot(XisPredicted{i}, 'k'); 
	hold on; 
	title('Learned Switches');
	
	for s = 1 : S
		tState = find(Shats{i} == s);
		plot(tState, XisPredicted{i}(tState), '.', 'color', stateColors(s, :), 'markersize', 10);
	end
end

figure;
plot(logLikelihood);
