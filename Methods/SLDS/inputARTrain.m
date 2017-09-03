function [A, Bjs, residual] = inputARTrain(V, U, Lv, Lu)
%ARTRAIN Fit autoregressive (AR) coefficients of order L to v.
% [a residual]=ARtrain(v,L)
%
% Inputs:
% v: observation sequence
% u: input sequence
% L : order of the AR model
% 
% Outputs:
% a : learned AR coefficients
% residual : error in the prediction of each point

% This uses a simple Gaussian Elimination solver
% -- Levinson Durbin is a recommended alternative

numVariables = length(U);
VVHat = zeros(Lv + Lu * numVariables, 1); 
V = V(:);

VHatVHat = zeros(Lv + Lu * numVariables);
for t = Lv+1 : length(V)
	VHat = V(t - Lv : t-1);
	for j = 1 : length(U)
		Uj = U{j};
		Uj = Uj(:);
		VHat = [VHat; Uj(t - Lu : t-1)]; %#ok
	end
	VVHat = VVHat + V(t) * VHat;
	VHatVHat = VHatVHat + VHat * VHat';
end
C = pinv(VHatVHat) * VVHat;

A = C(1 : Lv);
Bjs = cell(numVariables, 1);
for j = 1 : numVariables
	Bjs{j} = C(Lv+1 + Lu*(j-1) : Lv + Lu*j);
end

for t = Lv+1 : length(V(:))
	VHat = V(t - Lv : t-1);
	for j = 1 : numVariables
		Uj = U{j};
		Uj = Uj(:);
		VHat = [VHat; Uj(t - Lu : t-1)]; %#ok
	end
	residual(t) = V(t) - C' * VHat;
end

