function Xhat = SSMOPredict(X, Xmissing, Ujs, A, B, C)
%SSMOPREDICT One step ahead prediction of SSMO model
%   Detailed explanation goes here

T = length(X);
numInputs = length(Ujs);

UjsMat = zeros(T, numInputs);
for j = 1 : numInputs
	UjsMat(:, j) = Ujs{j};
end

U1 = UjsMat(4 : end, 1:4)';
U2 = UjsMat(3 : end-1, 1:4)';
U3 = UjsMat(2 : end-2, 1:4)';

D = [A, B, C];

Xhat = zeros(size(X));
Xhat(1 : 3) = X(1 : 3);
for t = 4 : T
	y = D * [X(t-1:-1:t-3)'; U3(:,t-3); U2(:,t-3); U1(:,t-3); 1];
	Xhat(t) = y(1);
	if isnan(Xmissing(t))
		X(t) = Xhat(t);
	end
end

end