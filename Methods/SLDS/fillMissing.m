function imputed = fillMissing(data, methodType)
	
	mask = isnan(data);
	mask = -mask;
	if strcmp(methodType, 'mean')
		for i = 1:size(data,2)
			data(mask(:,i) == -1,i ) = mean(data(mask(:,i)~=-1,i));
		end
		imputed = data;
	elseif strcmp(methodType , 'previous')
		for i = 1:size(data,2)
			for j = 2:size(data,1)
				if mask(j,i) == -1
					data(j,i) = data(j-1,i);
				end
			end
		end
		imputed = data;
	elseif strcmp(methodType, 'fda')
		range = [min(data(:,1)), max(data(:,1))];
		numberOfBasis = 50;
		order = 4;
		basis = create_bspline_basis(range, numberOfBasis, order);
	
		differential = int2Lfd(2);
		smoothingParams = logspace(0, -30, 200);
% 		smoothingParams = 10^-20;
		timePoints = data(:,1);
		
		imputed = data;
		for i = 1 : size(data, 2)
			bestError = realmax;
			for smoothingParam = smoothingParams
				try
					functionalParam = fdPar(basis, differential, smoothingParam);
					samples = data(mask(:,i) ~= -1, i);
					observedTimes = data(mask(:,i) ~= -1, 1);
					fdObj = smooth_basis(observedTimes, samples, functionalParam);
					fittedData = eval_fd(timePoints, fdObj);

					error = mean(abs(fittedData(mask(:,i) ~= -1) - samples));
					
					outOfBounds = max(fittedData) > max(data(:,i)) || min(fittedData) < min(data(:,i));

					if error < bestError && sum(outOfBounds) == 0
						imputed(:, i) = fittedData;
						bestError = error;
                    end
                catch
                    disp('');
                end
            end
		end
	elseif strcmp(methodType, 'haar')
% 		Same as FDA only with Haar basis. Consider refactoring
		range = [min(data(:,1)), max(data(:,1))];
		numberOfBasis = 4;
		basis = create_haar_basis(range, numberOfBasis);
	
		differential = int2Lfd(0);
		timePoints = data(:,1);
		
		imputed = data;
		for i = 1 : size(data, 2)
			functionalParam = fdPar(basis, differential);
			samples = data(mask(:,i) ~= -1, i);
			observedTimes = data(mask(:,i) ~= -1, 1);
			fdObj = smooth_basis(observedTimes, samples, functionalParam);
			fittedData = eval_fd(timePoints, fdObj);
			imputed(:, i) = fittedData;
		end
	else
		imputed = [];
	end
	
end

