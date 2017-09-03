function [gradX, gradU] = gradientLeastSquares(X, Ujs, A, Bjs, C, Lx, Lu, Shat)
%GRADIENTLEASTSQUARES Computes the gradient of state observations and input
% X and Ujs. Uses the linear dynamic model: X(t) = A*X(t-1) + B*U(t) + C
% [gradX, gradU] = gradientLeastSquares(X, Ujs, A, Bjs, C, Lx, Lu, Shat)
%
% Inputs:
% X            : State Observations
% Ujs          : Cell vector of input observations
% A            : Matrix of state coefficients
% Bjs          : Cell vector of input coefficients
% C            : Constant coefficient
% Lx and Lu    : Order of the AR model for state and inputs respectively.
% Shat         : Maximum likely state estimate 
%
% Outputs:
% gradX   : Gradient of X
% gradU   : Gradient of U

T = length(X);
numInputs = length(Ujs);

UjsMat = zeros(T, numInputs);
for j = 1 : numInputs
	UjsMat(:, j) = Ujs{j};
end

X = X(:);
Xp = zeros(Lx+1, T-Lx);
for i = 1 : Lx+1
	Xp(i, :) = X(Lx+1 - (i-1) : end - (i-1))';
end

UjsMat = zeros(T, numInputs);
for j = 1 : numInputs
	UjsMat(:, j) = Ujs{j};
end

U = zeros(numInputs * Lu, T - Lx);
for i = 1 : Lu
	U(numInputs * (i-1) + 1 : numInputs * i, 1 : T - Lu) = UjsMat(Lu+1 - (i-1) : T - (i-1), :)';
end

% Compute X Gradient
gradXp = zeros(Lx+1, T-Lx);
for i = 1 : T-Lx
	Ap = zeros(Lx+1);
	Ap(2 : end, 2 : end) = eye(Lx);
	Ap(1, 2 : end) = A(:, Shat(i))';
	
	% Construct Bp according to U (switch state -- input variables -- order)
	Bp = zeros(Lx + 1, numInputs * Lu);
	for j = 1 : numInputs
		for k = 1 : Lu
			Bp(1, j + numInputs * (k-1)) = Bjs{j}(k, Shat(i));
		end
	end
	
	Cp = C(Shat(i));
	
	gradXp(:, i) = (eye(size(Ap,1)) - Ap)' * ((eye(size(Ap,1)) - Ap) * Xp(:, i) - Bp*U(:, i) - Cp);
end

gradXTemp = zeros(Lx+1, T);
for i = 1 : Lx+1
	gradXTemp(i, Lx+1 - (i-1) : end - (i-1)) = gradXp(i, :);
end
gradX = ones(1, Lx+1) * gradXTemp;

Xp = zeros(Lx+1, T-Lx);
for i = 1 : Lx+1
	Xp(i, :) = X(Lx+1 - (i-1) : end - (i-1))';
end

% Compute Ujs Gradient
gradU = zeros(numInputs*Lu, T-Lu);
for i = 1 : T-Lx
	Ap = zeros(Lx+1);
	Ap(2 : end, 2 : end) = eye(Lx);
	Ap(1, 2 : end) = A(:, Shat(i))';
	
	% Construct Bp according to U (switch state -- input variables -- order)
	Bp = zeros(Lx + 1, numInputs * Lu);
	for j = 1 : numInputs
		for k = 1 : Lu
			Bp(1, j + numInputs * (k-1)) = Bjs{j}(k, Shat(i));
		end
	end
	
	Cp = C(Shat(i));
	
	gradU(:, i) = Bp' * (Bp*U(:, i) + Cp - (eye(size(Ap, 1)) - Ap) * Xp(:, i));
end

gradUTemp = zeros(numInputs * Lu, T);
for i = 1 : Lu
	gradUTemp(numInputs * (i-1) + 1 : numInputs * i, Lu+1 - (i-1) : end - (i-1)) = gradU(numInputs * (i-1) + 1 : numInputs * i, 1 : T-Lu);
end

I = zeros(numInputs, numInputs * Lu);
for i = 1 : Lu
	I(:, numInputs * (i-1) + 1 : numInputs * i) = eye(numInputs);
end
gradU = I * gradUTemp;

end