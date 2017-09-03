function imputedData = paceImpute(data, observedTimes, time, subject, options)
%PACEIMPUTE Summary of this function goes here
%   Detailed explanation goes here

Yprime = FPCA(data, observedTimes, options);
imputedData = cell2mat(FPCAeval(Yprime, subject, time));

end

