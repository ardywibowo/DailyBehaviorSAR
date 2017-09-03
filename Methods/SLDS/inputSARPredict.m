function [Xpredict, SHats] = inputSARPredict(X, Xmissing, Ujs, A, Bjs, C, pS1, sTrans, sigma2, Tskip)
% INPUTGROUPSARPREDICT Summary of this function goes here
% [Xpredict, Shat] = inputSARPredict(X, Ujs, A, Bjs, C, St, sTrans, sigma2, Tskip, numPred, numIter)
% Inputs:
% X        : Row vector of observations
% Ujs      : Cell vector. Each cell containing an input row vector.
% A        : AR coefficients for x. Shared between each
%            subject.
% Bjs      : Cell vector. Each cell contains learned AR coefficients for
%            different input types Uis, shared between each subject.
% C        : Constant Coefficient
% sTrans   : Transition distribution
%
% Outputs:
% Xpredict : Estimated states
% Shat     : Most likely hidden switching variables

import brml.*
%% Initialize values
T = length(X);

Xpredict = zeros(1, T);
Xpredict(1) = X(1);

SHats = zeros(1, T);

for t = 2 : T
	[SHat, ~] = HMMinputViterbi(X, Ujs, t, A, Bjs, C, pS1, sTrans, sigma2, Tskip);
	if t == 2
		SHats(1) = SHat(1);
	end
	
	[~, SHats(t)] = max(sTrans(:, SHat(end)));
	[XHat, ~, ~] = sarMean(X, Ujs, t, A, Bjs, C);
	Xpredict(t) = XHat(SHats(t));
	
	if isnan(Xmissing(t))
		X(t) = XHat(SHats(t));
	end
end

end
