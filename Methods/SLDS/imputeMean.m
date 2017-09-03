function [Xtilde, UjTildes] = imputeMean(X, Ujs)
%IMPUTEMEAN Imputes the mean value on both X and Ujs
% [Xtilde, UjTildes] = imputeMean(X, Ujs)
%
% Inputs:
% X   : State Observations
% Ujs : Cell vector of input observations
%
% Outputs:
% Xtilde   : Imputation of X
% UjTildes : Imputation of Ujs

Xtilde = X;
UjTildes = Ujs;

Xtilde(isnan(Xtilde)) = nanmean(Xtilde);

for i = 1 : length(Ujs)
	currentUs = Ujs{i};
	currentUs(isnan(currentUs)) = nanmean(currentUs);
	UjTildes{i} = currentUs;
end

end

