clear; close all; clc;
format long;

% Get Data with user ID
userInformation		= readtable('../Data/users_sample.csv');
userId = userInformation.mfp_user_id;
userId = sort(userId);

% Format data without user ID
data = readtable(strcat('../Users/', num2str(userId(2)), '.csv'));
data.mmf_user_id = [];
data.mfp_user_id = [];
data = table2cell(data);

% Get numeric columns of data. Missing values as NaN
numeric = cellfun(@(x) isnumeric(x) && numel(x)==1, data);
isAllNum = all(numeric,1);
numericData = cell2mat(data(:,isAllNum));

% Center data. The mean and all NaN values being 0
dataMean = nanmean(numericData, 1);
dataMean(isnan(dataMean)) = 0;

% Create initial input, setting missing values to mean = 0
inputData = bsxfun(@minus, numericData, dataMean);
inputData(isnan(inputData)) = 0;

% Create roughness penalty matrices as fourth order difference matrices
Omegu = toeplitz([ 2 -1 zeros(1, size(inputData, 1) - 2) ]);
Omegv = toeplitz([ 2 -1 zeros(1, size(inputData, 2) - 2) ]);

% Create sparsity and smoothness vectors 
lamus		= 0;
lamvs		= linspace(0, 1.5, 10);
alphaus = linspace(0, 1.5, 10);
alphavs = 0;

change = realmax;
p = 0;
while change > 10^-8
	% Apply SFPCA Iteratively fitting the data.
	[U,V,d,optaus,optavs,optlus,optlvs,Xhat,bicu,bicv] = ... 
	sfpca_nested_bic(inputData, 10, lamus, lamvs, alphaus, alphavs, Omegu, Omegv, 0, 0, 0, 0, 10000, 100);

% 	[U, S, V] = svds(inputData, 2, 'largest');
% 	Create reconstructed matrix
	S = diag(d);
	reconstructedData = U*S*ctranspose(V);
	
	% Set new input
	inputData(isnan(numericData)) = reconstructedData(isnan(numericData));
	
	% Check error
	difference = abs(reconstructedData - inputData).^2;
	init = abs(inputData).^2;
	change = sum(difference(:)) / sum(init(:));
	fprintf('Change is: %d\n', change);
	
	p = p + 1;
end

reconstructedData = bsxfun(@plus, reconstructedData, dataMean);
imputedData = bsxfun(@plus, inputData, dataMean);

hold all;
% plot(imputedData(:, 10), 'b');
plot(numericData(:, 10), 'r');
plot(reconstructedData(:, 10), 'g');
xlabel('Time'), ylabel('BMI');

% disp(optlus);
% disp(optlvs);
% disp(optaus);
% disp(optavs);