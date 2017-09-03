function nextState = simulateTransition(Ptrans)
%SIMULATETRANSITION Summary of this function goes here
%   Detailed explanation goes here

randNum = rand;

currentThres = 0;
k = 1;
for p = 1 : length(Ptrans)
	currentThres = currentThres + p;
	if randNum <= currentThres
		nextState = k;
		break;
	end
	k = k + 1;
end

end

