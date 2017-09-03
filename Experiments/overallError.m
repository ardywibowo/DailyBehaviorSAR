function [meanError, stdError] = overallError(errorMatrix)
%OVERALLERROR Summary of this function goes here
%   Detailed explanation goes here

meanError = mean(errorMatrix, 2);
stdError = std(errorMatrix'); %#ok
disp('Errors:');
disp(['ABS: ' num2str(meanError(1)) ' +- ' num2str(stdError(1))]);
disp(['RMSE: ' num2str(meanError(2)) ' +- ' num2str(stdError(2))]);


end

