function [means, XHat, UHat] = sarMean(X, Ujs, t, A, Bjs, C)
%SARMEAN Calculates X(t)'s expectation according to the linear dynamic model
% X(t) = A*X(t-1) + B*U(t) + C
% [means, XHat, UHat] = sarMean(X, Ujs, t, A, Bjs, C)
%
% Inputs :
% X   : State observations
% Ujs : Cell vector of input observations
% A   : Matrix of state coefficients
% Bjs : Cell vector of input coefficients
% C   : Constant coefficient
%
% Outputs :
% means : Column vector, each row representing a different state

Lx = size(A, 1);
Ltx = min(t-1, Lx); % To handle the start when not enough timepoints
XHat = zeros(Lx, 1);
XHat(end - Ltx + 1 : end) = X(t - Ltx : t - 1)';

means = A' * XHat;

UHat = [];
if (iscell(Ujs))
	for j = 1 : length(Ujs)
		Uj = Ujs{j};
		Bj = Bjs{j};
		[Lu, ~] = size(Bj);
		Ltu = min(t-1, Lu); % To handle the start when not enough timepoints

		UjHat = zeros(Lu, 1);
		UjHat(end - Ltu + 1 : end) = Uj(t - Ltu + 1 : t)';	
		UHat = [UHat; UjHat]; %#ok

		means = means + Bj' * UjHat; % Means
	end
end

means = means + C';

end