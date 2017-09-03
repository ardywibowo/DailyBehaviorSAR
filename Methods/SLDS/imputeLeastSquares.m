function [Xtilde, UjTildes] = imputeLeastSquares(X, Ujs, Xmissing, UiMissings, A, Bjs, C, Lx, Lu, pStGivenX1Ts, parameters)
%IMPUTELEASTSQUARES Imputes missing values on observation and input vectors
% [Xtilde, UjTildes] = imputeLeastSquares(X, Ujs, Xmissing, UiMissings, A, Bjs, C, Lx, Lu, pStGivenX1Ts, parameters)
%
% using least squares on the linear dynamic model: X(t) = A*X(t-1) + B*U(t) + C
% Inputs:
% X            : State Observations
% Ujs          : Cell vector of input observations
% A            : Matrix of state coefficients
% Bjs          : Cell vector of input coefficients
% C            : Constant coefficient
% Lx and Lu    : Order of the AR model for state and inputs respectively.
% pStGivenX1Ts : Smoothed posterior p(S(t)|X(1:T))
% parameters   : Vector of 6 coefficients. The parameters are as follows:
%    yitaX        : Step size for X missing value gradient descent
%    yitaU        : Step size for U missing value gradient descent
%    alphaX       : Step size for X outlier gradient descent
%    alphaU       : Step size for U outlier gradient descent
%    deltaX       : Number of outliers on X to impute
%    deltaU       : Number of outliers on U to impute
%
% Outputs:
% Xtilde   : Imputation of X
% UjTildes : Imputation of Ujs

T = length(X);
numInputs = length(Bjs);
UjTildes = cell(size(Ujs, 2), 1);

UjsMat = zeros(T, numInputs);
for j = 1 : numInputs
	UjsMat(:, j) = Ujs{j};
end

% Find the most likely MPM switches
[~, Shat] = max(pStGivenX1Ts, [], 1);

% Initialize Parameters
yitaX  = parameters(1);
yitaU = parameters(2);
alphaX  = parameters(3);
alphaU = parameters(4);
deltaX = parameters(5);
deltaU = parameters(6);

% Impute X and Ujs missing values
[gradX, gradU] = gradientLeastSquares(X, Ujs, A, Bjs, C, Lx, Lu, Shat);
Xestimate = X - yitaX*gradX;
X(Xmissing == 1) = Xestimate(Xmissing == 1);

Uestimate = UjsMat - (yitaU * gradU)';
UjsMat(UiMissings == 1) = Uestimate(UiMissings == 1);
for j = 1 : numInputs
	Ujs{j} = UjsMat(:, j);
end

% Impute X and Ujs outliers
[gradX, gradU] = gradientLeastSquares(X, Ujs, A, Bjs, C, Lx, Lu, Shat);
Xestimate = X - alphaX*gradX;

disX = TopNinMatrix(abs(Xestimate - X), deltaX);
numOutliersX = size(disX, 1);
for j = 1 : numOutliersX
	X(disX(j, 2), disX(j, 3)) = Xestimate(disX(j, 2), disX(j, 3));
end

Uestimate = UjsMat - (alphaU * gradU)';
disU = TopNinMatrix(abs(Uestimate - UjsMat), deltaU);
numOutliersU = size(disU, 1);
for j = 1 : numOutliersU
	UjsMat(disU(j, 2), disU(j, 3)) = Uestimate(disU(j, 2), disU(j, 3));
end

Xtilde = X;
for j = 1 : numInputs
	UjTildes{j} = UjsMat(:, j);
end

end