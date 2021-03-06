clear; close all; %clc;

addpath('./PACE');
[d,v,nv] = raw_data_separation('orig139.tsv');
vla = importdata('range_bmi.mat');

% Number of users
rr = 1:length(d)-1;

% Setup y and t for FPCA. Each cell is an array
[dataTemplate, ~, ~, ~] = selectperson(d, v, nv, 1);
y = cell(size(dataTemplate, 2), max(rr));
t = cell(size(dataTemplate, 2), max(rr));
p = setOptions('numBins', 0, 'bwmu_gcv', 0, 'maxk', 200, 'ngrid1', 102, 'ngrid', 202, 'ntest1', 102, 'selection_k', 'BIC');
imputedData = cell(1, max(rr));

% Put the ID and time points of each person into final matrix first
for i = 1:numel(rr)
	[dataTemplate, normalized, ~, ~] = selectperson(d, v, nv, i);
	
	tOut = normalized(:,1);
	idOut = normalized(:,2);
	
	imputedData{i} = NaN(size(tOut, 1), size(normalized, 2));
	
	imputedData{i}(:,1) = tOut;
	imputedData{i}(:,2) = idOut;
end

% Do PACE Imputation
for i = 3 : size(dataTemplate, 2)
	% Gather all data for a single variable from all people
	for j = 1 : numel(rr)
		[train, ntrain, ~, ~] = selectperson(d, v, nv, j);
		notEmpty = (train ~= -1);
		y{i, j} = ntrain(notEmpty(:, i), i)';
		t{i, j} = ntrain(notEmpty(:, i), 1)';
	end

	% Perform FPCA using PACE
	[yy] = FPCA(y(i, :), t(i, :), p);
	
	% Evaluate FPCA for the respective time points for each user
	for j = 1 : numel(rr)
		currentTOut = imputedData{j}(:,1);
		yPred = FPCAeval(yy, [], currentTOut);
		
		%	yPred is a column vector of all users on the current variable i
		imputedData{j}(:,i) = yPred{j,1};
	end
end

for i = 1:numel(rr)
	csvwrite(strcat('PACE Imputed Data/', num2str(rr(i)), '.csv'), imputedData{i});
end

% for i = 1:numel(rr)
% 	user = vertcat(user, csvread(strcat('PACE Imputed Data/', num2str(i), '.csv')));	
% end