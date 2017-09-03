clear; close all; clc;

numberOfMethods = 6;
numberOfUsers = 27;

load('error.mat');
load('errorMSE.mat');

minimumErrorMSE = zeros(numberOfMethods, numberOfUsers);
minimumErrorABS = zeros(numberOfMethods, numberOfUsers);
for i = 1:numberOfUsers
    for j = 1:numberOfMethods
        minimumErrorMSE(j,i) = min(errorMSE(j, 100*(i-1)+1:i*100));
        minimumErrorABS(j,i) = min(error(j, 100*(i-1)+1:i*100));
    end
end

sum(minimumErrorMSE, 2)
sum(minimumErrorABS, 2)
