clear; clc; close all;

% Add dependencies
addpath('./PACE');
[d,v,nv] = raw_data_separation('orig139.tsv');
vla = importdata('range_bmi.mat');

% Number of users
rr = 1:length(d)-1;

% PACE Options
p = setOptions('regular', 0, 'selection_k', 'FVE', 'FVE_threshold', 0.9, 'kernel', 'gauss', 'bwmu_gcv', 0);

for i = 1:dataMasknumel(rr)
	[, ntrain, ~, ~] = selectperson(d, v, nv, i);
	
	tOut = ntrain(:,1);
% 	idOut = ntrain(:,2);
	
% 	imputedData = NaN(size(dataMask));
	
% 	imputedData(:,1) = tOut;
% 	imputedData(:,2) = idOut;
	imputedData = ntrain;
	for j = 3:size(dataMask, 2)
		
		notEmptyData = ntrain(dataMask(:, j) ~= -1, j)';
		notEmptyTimes = ntrain(dataMask(:, j) ~= -1, 1)';
		
		notEmptyData1 = notEmptyData(1 : floor(numel(notEmptyData)/2));
		notEmptyData2 = notEmptyData(floor(numel(notEmptyData)/2) + 1 : numel(notEmptyData));
		
		notEmptyTimes1 = notEmptyTimes(1 : floor(numel(notEmptyData)/2));
		notEmptyTimes2 = notEmptyTimes(floor(numel(notEmptyData)/2) + 1 : numel(notEmptyData));
		
		y{1} = notEmptyData1;
		t{1} = notEmptyTimes1;
		y{2} = notEmptyData2;
		t{2} = notEmptyTimes2;
		
% 		y{1} = ntrain(dataMask(:, j) ~= -1, j)';
% 		t{1} = ntrain(dataMask(:, j) ~= -1, 1)';
% 		
% 		y{2} = ntrain(dataMask(:, j) ~= -1, j)';
% 		t{2} = ntrain(dataMask(:, j) ~= -1, 1)';
		
% 		y = cell(1, sum(dataMask(:,j) ~= -1));
% 		t = y;
% 		l = 1;		
% 		for k = 1:size(dataMask, 1)
% 			if dataMask(k, j) ~= -1
% 				y{l} = ntrain(k, j);
% 				t{l} = ntrain(k, 1);
% 				
% 				l = l + 1;
% 			end
% 		end
		
		[yy] = FPCA(y, t, p);
		yPred = FPCAeval(yy, [], tOut);
		
% 		empty = (dataMask(:, j) == -1);
		imputedData(:, j) = yPred{1};	
	end
	
	save(strcat('PACE Original/', num2str(rr(i)), '.mat'), 'imputedData');
end