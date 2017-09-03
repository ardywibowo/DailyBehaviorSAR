function [ fdata ] = MissingFilling( data,mask, selection )
	
% 	addpath('./fdaM');
	
	if strcmp(selection, 'mean')
		for i = 1:size(data,2)
			data(mask(:,i) == -1,i ) = mean(data(mask(:,i)~=-1,i));
		end
		fdata = data;
	elseif strcmp(selection , 'previous')
		for i = 1:size(data,2)
			for j = 2:size(data,1)
				if mask(j,i) == -1
					data(j,i) = data(j-1,i);
				end
			end
		end
		fdata = data;
	elseif strcmp(selection, 'fda')
		range = [min(data(:,1)), max(data(:,1))];
		numberOfBasis = 100;
		order = 10;
		basis = create_bspline_basis(range, numberOfBasis, order);
	
		differential = int2Lfd(4);
		smoothingParams = logspace(0, -30, 200);
% 		smoothingParams = 10^-20;
		timePoints = data(:,1);
		
		fdata = data;
		for i = 1 : size(data, 2)
			bestError = realmax;
			for smoothingParam = smoothingParams
				try
					functionalParam = fdPar(basis, differential, smoothingParam);
					samples = data(mask(:,i) ~= -1, i);
					observedTimes = data(mask(:,i) ~= -1, 1);
					smoothedSampleBasis = smooth_basis(observedTimes, samples, functionalParam);
					fittedData = eval_fd(timePoints, smoothedSampleBasis);

					error = mean((fittedData(mask(:,i) ~= -1) - samples).^2);
					
					outOfBounds = max(fittedData) > max(data(:,i)) || min(fittedData) < min(data(:,i));

					if error < bestError && sum(outOfBounds) == 0
						disp('Yay');
						fdata(:, i) = fittedData;
						bestError = error;
					end
				catch
				end
				disp('Iterated!');
			end
			disp('Done!');
		end
	else
		fdata = [];
	end
	
end

