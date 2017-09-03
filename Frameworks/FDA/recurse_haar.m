function haarSubmatrix = recurse_haar(currentLevel, range, levels, evalargin)
%RECURSE_HAAR Summary of this function goes here
%   Detailed explanation goes here

% if currentLevel == 1
% 	haarSubmatrix(:, 1) = ones(length(evalargin), 1);
% 	haarSubmatrix = [haarSubmatrix, ...
% 		recurse_haar(currentLevel+1, [min(evalargin) max(evalargin)], levels, evalargin)];
% 	return;
% elseif currentLevel == levels
% 	midpoint = (range(1)+range(2))/2;
% 	haarSubmatrix(:, 1) = zeros(length(evalargin), 1);
% 	haarSubmatrix(evalargin >= range(1) & evalargin <= midpoint, 1) = 1;
% 	haarSubmatrix(evalargin >= midpoint & evalargin <= range(2), 1) = -1;
% 	return;
% end
% 
% midpoint = (range(1)+range(2))/2;
% haarSubmatrix(:, 1) = zeros(length(evalargin), 1);
% haarSubmatrix(evalargin >= range(1) & evalargin <= midpoint, 1) = 1;
% haarSubmatrix(evalargin >= midpoint & evalargin <= range(2), 1) = -1;
% 
% haarSubmatrix = [haarSubmatrix, ...
% 	recurse_haar(currentLevel+1, [range(1) midpoint], levels, evalargin) ...
% 	recurse_haar(currentLevel+1, [midpoint range(2)], levels, evalargin)];

if currentLevel == 1
	haarSubmatrix(:, 1) = ones(length(evalargin), 1);
	haarSubmatrix = [haarSubmatrix, ...
		recurse_haar(currentLevel+1, [1 length(evalargin)], levels, evalargin)];
	return;
elseif currentLevel == levels
	midpoint = floor((range(1)+range(2))/2);
	haarSubmatrix(:, 1) = zeros(length(evalargin), 1);
	haarSubmatrix(range(1) : midpoint, 1) = 1;
	haarSubmatrix(midpoint + 1 : range(2), 1) = -1;
	return;
end

midpoint = floor((range(1)+range(2))/2);
haarSubmatrix(:, 1) = zeros(length(evalargin), 1);
haarSubmatrix(range(1) : midpoint, 1) = 1;
haarSubmatrix(midpoint + 1 : range(2), 1) = -1;

haarSubmatrix = [haarSubmatrix, ...
	recurse_haar(currentLevel+1, [range(1) midpoint], levels, evalargin) ...
	recurse_haar(currentLevel+1, [midpoint+1 range(2)], levels, evalargin)];


end

