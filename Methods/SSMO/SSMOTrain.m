function [Xtilde, UjTildes, A, Bjs, C] = SSMOTrain(X, Ujs, parameters, maxIter)
%SSMOTRAIN Train linear dynamic model using 3rd order SSMO
% [Xtilde, UjTildes, A, Bjs, C] = SSMOTrain(X, Ujs, parameters, maxIter)
%
% Inputs:
% X            : State Observations
% Ujs          : Cell vector of input observations
% parameters   : Vector of 6 coefficients. The parameters are as follows:
%    yitaX        : Step size for X missing value gradient descent
%    yitaU        : Step size for U missing value gradient descent
%    alphaX       : Step size for X outlier gradient descent
%    alphaU       : Step size for U outlier gradient descent
%    deltaX       : Number of outliers on X to impute
%    deltaU       : Number of outliers on U to impute
% maxIter      : Maximum number of descent iterations
%
% Outputs:
% Xtilde   : Imputation of X
% UjTildes : Imputation of Ujs
% A        : Matrix of state coefficients
% Bjs      : Cell vector of input coefficients
% C        : Constant coefficient

T = length(X);
numInputs = length(Ujs);

% Initialize X and U
Xmissing = isnan(X);

UjsMat = zeros(T, numInputs);
for j = 1 : numInputs
	UjsMat(:, j) = Ujs{j};
end
Umissing = isnan(UjsMat);

[X, Ujs] = imputeMean(X, Ujs);

X = X(:);
Xp = [X(4 : end)'; X(3 : end-1)'; X(2 : end-2)'; X(1 : end-3)'];

UjsMat = zeros(T, numInputs);
for j = 1 : numInputs
	UjsMat(:, j) = Ujs{j};
end

U1 = UjsMat(4 : T, 1:4)';
U2 = UjsMat(3 : T-1, 1:4)';
U3 = UjsMat(2 : T-2, 1:4)';
U = [U1; U2; U3];

% Initialize Parameters
yitaX  = parameters(1);
yitaU = parameters(2);
alphaX  = parameters(3);
alphaU = parameters(4);
deltaX = parameters(5);
deltaU = parameters(6);

% Initialize Coefficients
Ap = zeros(4, 4);
Ap(4, 4) = 1;
Bp = zeros(4, 12);
Cp = zeros(4, size(Xp, 2));
gradXTemp = zeros(4, T);
gradUTemp = zeros(12, T);

objective = zeros(1, maxIter);
for i = 1 : maxIter
	Xtemp = Xp(1:3, :);
	Y = [Xp(2:4, :); U; ones(1, size(U, 2))];
	D = Xtemp * pinv(Y);
	
	objective(i) = 0.5 * norm((Xtemp - D*Y).^2, 'fro');
	
	Ap(1:3, 2:4) = D(:, 1 : 3);
	Bp(1:3, :) = D(:, 4 : end-1);
	Cp(1:3, :) = D(:, end) * ones(1, size(Xtemp, 2));
	
	% Impute X missing values
	gradXp = (eye(size(Ap,1)) - Ap)' * ((eye(size(Ap,1)) - Ap) * Xp - Bp*U - Cp);
	gradXTemp(1, 4 : end)   = gradXp(1, :);
	gradXTemp(2, 3 : end-1) = gradXp(2, :);
	gradXTemp(3, 2 : end-2) = gradXp(3, :);
	gradXTemp(4, 1 : end-3) = gradXp(4, :);
	gX = ones(1, 4) * gradXTemp;
	Xestimate = X - (yitaX * gX)';
	X(Xmissing == 1) = Xestimate(Xmissing == 1);
	Xp = [X(4:end)'; X(3:end-1)'; X(2:end-2)'; X(1:end-3)'];
	
	% Impute Ujs missing values
	gradU = Bp' * (Bp*U + Cp - (eye(size(Ap, 1)) - Ap) * Xp);
	gradUTemp(1:4, 4:end) = gradU(1:4, :);
	gradUTemp(5:8, 3:end-1) = gradU(5:8, :);
	gradUTemp(9:12, 2:end-2) = gradU(9:12, :);
	gradU = [eye(4), eye(4), eye(4)] * gradUTemp;
	Uestimate = UjsMat - (yitaU*gradU)';
	UjsMat(Umissing == 1) = Uestimate(Umissing == 1);
	U1 = UjsMat(4 : T, 1 : 4)';
	U2 = UjsMat(3 : T-1, 1 : 4)';
	U3 = UjsMat(2 : T-2, 1 : 4)';
	U = [U1; U2; U3];
	
	% Impute X outliers
	gradXp = (eye(size(Ap,1))-Ap)' * ((eye(size(Ap,1)) - Ap)*Xp - Bp*U - Cp);
	gradXTemp(1, 4:end) = gradXp(1, :);
	gradXTemp(2, 3:end-1) = gradXp(2, :);
	gradXTemp(3, 2:end-2) = gradXp(3, :);
	gradXTemp(4, 1:end-3) = gradXp(4, :);
	gX = ones(1, 4) * gradXTemp;
	Xestimate = X - (alphaX*gX)';
	disX = TopNinMatrix(abs(Xestimate - X), deltaX);
	for j = 1 : size(disX, 1)
		X(disX(j, 2), disX(j, 3)) = Xestimate(disX(j, 2), disX(j, 3));
	end
	Xp = [X(4 : end)'; X(3 : end-1)'; X(2 : end-2)'; X(1 : end-3)'];
	
	% Imput Ujs outliers
	gradU = Bp' * (Bp*U + Cp - (eye(size(Ap,1)) - Ap) * Xp);
	gradUTemp(1 : 4, 4 : end) = gradU(1 : 4, :);
	gradUTemp(5 : 8, 3 : end-1) = gradU(5 : 8, :);
	gradUTemp(9 : 12, 2 : end-2) = gradU(9 : 12, :);
	gradU = [eye(4), eye(4), eye(4)] * gradUTemp;
	Uestimate = UjsMat - (alphaU * gradU)';
	disU = TopNinMatrix(abs(Uestimate - UjsMat), deltaU);
	for j = 1 : size(disU, 1)
		UjsMat(disU(j, 2), disU(j, 3)) = Uestimate(disU(j, 2), disU(j, 3));
	end
	U1 = UjsMat(4 : T, 1 : 4)';
	U2 = UjsMat(3 : T-1, 1 : 4)';
	U3 = UjsMat(2 : T-2, 1 : 4)';
	U = [U1; U2; U3];
end

Xtilde = X;

UjTildes = cell(size(Ujs));
for j = 1 : numInputs
	UjTildes{j} = UjsMat(:, j);
end

A = D(:, 1 : 3);
Bjs = D(:, 4 : end-1);
C = D(:, end);

end