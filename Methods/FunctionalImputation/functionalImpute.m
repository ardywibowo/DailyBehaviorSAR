function imputedData = functionalImpute(data, missingMask, time, imputationMethod)
%FUNCTIONALIMPUTE Summary of this function goes here
%   Detailed explanation goes here

imputedData = data;
if strcmp(imputationMethod, 'mean')
	for i = 1 : size(data, 1)
		imputedData(i, isnan(missingMask(i, :))) = nanmean(data(i, :));
	end
elseif strcmp(imputationMethod, 'previous')
	for i = 1 : size(data, 1)
		if isnan(missingMask(i, 1))
			data(i, 1) = nanmean(data(i, :));
		end
		lastObserved = 1;
		for j = 2 : size(data, 2)
			if isnan(missingMask(i, j))
				if ~isnan(missingMask(i, j-1))
					lastObserved = j-1;
				end
				imputedData(i, j) = data(i, lastObserved);
			end
		end
	end
	imputedData(i, isnan(missingMask(i, :))) = nanmean(imputedData(i, :));
elseif strcmp(imputationMethod, 'bspline')
	for i = 1 : size(data, 1)
		bestError = realmax;
		
		range = [min(time), max(time)];
		numberOfBasis = 50;
		order = 4;
		basis = create_bspline_basis(range, numberOfBasis, order);

		differential = int2Lfd(2);
		smoothingParams = 10^-5;
		
		for smoothingParam = smoothingParams
			functionalParam = fdPar(basis, differential, smoothingParam);
			samples = data(i, ~isnan(missingMask(i, :)));
			observedTimes = time(~isnan(missingMask(i, :)));

			fdObj = smooth_basis(observedTimes, samples, functionalParam);
			fittedData = eval_fd(time, fdObj);
			fittedData  = fittedData';

			error = mean(( fittedData(~isnan(missingMask(i, :))) - samples ).^2);

% 			outOfBounds = max(fittedData) > max(data(:,i)) || min(fittedData) < min(data(:,i));

			if error < bestError
				imputedData(i, :) = fittedData;
				bestError = error;
			end
		end
	end
elseif strcmp(imputationMethod, 'haar')
	for i = 1 : size(data, 1)
		samples = data(i, ~isnan(missingMask(i, :)));
		
		observedTimes = time(~isnan(missingMask(i, :)));
		if mod(length(samples), 2) == 1
			samples = [samples, samples(end)]; %#ok
			observedTimes = [observedTimes, 2*observedTimes(end) - observedTimes(end-1)]; %#ok
		end
		
		if mod(length(time), 2) == 1
			time = [time, 2*time(end) - time(end-1)]; %#ok
			odd = 1;
		else
			odd = 0;
		end
		range = [min(time), max(time)];
		
		numberOfBases = [16 32];
		
		for numberOfBasis = numberOfBases
			try
				basis = create_haar_basis(range, numberOfBasis);

				functionalParam = fdPar(basis);

				fdObj = smooth_basis(observedTimes, samples, functionalParam);
				fittedData = eval_fd(time, fdObj);

				if odd
					imputedData(i, :) = fittedData(1 : end-1);
				else
					imputedData(i, :) = fittedData;
				end
			catch
				disp('Gotem');
			end
		end
	end
elseif strcmp(imputationMethod, 'pace')
	
else
	imputedData = [];
end

end

