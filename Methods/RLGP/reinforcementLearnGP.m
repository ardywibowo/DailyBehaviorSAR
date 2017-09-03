function piStar = reinforcementLearnGP(X1, UjRange, A, Bjs, C, sTrans, pS1, delta, gamma, Xstar, sigmaXStar, Tsim, maxIter)
%REINFORCEMENTLEARNGP Summary of this function goes here
%   Detailed explanation goes here

S = size(A, 2);
numVars = length(UjRange);

iterations = 0;
difference = Inf;

piStar = cell(numVars, 1);

while difference > delta && iterations < maxIter
	disp(iterations);
	Xsim = zeros(S, Tsim);
	Xsim(:, 1) = X1;
	
	SHats = zeros(1, Tsim);
	randState = simulateTransition(pS1);
	SHats(1) = randState;
	
	PSt = zeros(S, Tsim+1);
	PSt(:, 1) = sTrans(:, SHats(1));
	
	UjsSim = cell(numVars, 1);
	% Act according to current policy
	if iterations == 0
		% Initial policy
		for j = 1 : numVars
			UjsSim{j}(1) = UjRange(j, 1);
		end
	else
		% Construct estimated policy using GP
		for j = 1 : numVars
			UjsSim{j}(1) = predict(piStar{j}, Xsim(SHats(1), 1));
		end
	end
	
	% Simulate Tsim transitions using the model
	for t = 2 : Tsim
		% Generate Transition
		pTrans = sTrans(:, SHats(t-1));
		randState = simulateTransition(pTrans);
		SHats(t) = randState;
		
		% Act according to current policy
		if iterations == 0
			% Initial policy
			for j = 1 : numVars
				randWeight = rand;
				UjsSim{j}(t) = randWeight * UjRange(j, 1) + (1 - randWeight) * UjRange(j, 2);
			end
		else
			% Construct estimated policy using GP
			for j = 1 : numVars
				UjsSim{j}(t) = predict(piStar{j}, Xsim(SHats(t), t));
			end
		end
		
		[XHat, ~, ~] = sarMean(Xsim(SHats(t), :), UjsSim, t, A, Bjs, C);
		Xsim(:, t)  = XHat;
		
		PSt(:, t) = sTrans(:, SHats(t-1));
	end
	PSt(:, Tsim + 1) = sTrans(:, SHats(t));
	
	% Compute rewards and estimate the value function
	Xobs = zeros(1, Tsim);
	for t = 1 : Tsim
		Xobs(t) = Xsim(SHats(t), t);
	end
	Rsim = normpdf(Xobs, Xstar, sigmaXStar); % Gaussian rewards on optimal X
	Vpi = zeros(1, Tsim);
	
	Vpi(Tsim) = Rsim(:, Tsim);
	for t = Tsim-1 : -1 : 1
		Vpi(t) = Rsim(:, t) + gamma * Vpi(t+1);
	end
	
	% Construct a GP on the value function
	GPv = fitrgp(Xobs', Vpi', 'KernelFunction', 'squaredexponential');
	
	% Compute the Q function for all actions
	Q = zeros(Tsim);
	Uhats = zeros(numVars, Tsim);
	for i = 1 : Tsim
		XobsPrime = repmat(Xobs(:, i), 1, numVars * Tsim);
		UjsPrime = cell(numVars, 1);
		for k = 1 : numVars * Tsim
			for j = 1 : numVars
				randInt = randi(Tsim);
				UjsPrime{j}(k) = UjsSim{j}(randInt);
			end
			[Xnext, ~, ~] = sarMean(XobsPrime, UjsPrime, k, A, Bjs, C);
			
			Riks = normpdf(XobsPrime(:, i), Xstar, sigmaXStar);
			Rik = sum(Riks .* PSt(i));
			
			Q(i, k) = Rik + gamma * sum(predict(GPv, Xnext) .* PSt(i+1));
		end
		
		% Estimate the Q function using a Gaussian Process
		XobsPrime = XobsPrime';
		GPqTable = table(XobsPrime);
		tempTable = table();
		for j = 1 : numVars
			name = ['Input', num2str(j)];
			currentTable = table(UjsPrime{j}', 'VariableNames', {name});
			tempTable = [tempTable currentTable]; %#ok
		end
		GPqTable = [GPqTable, tempTable]; %#ok
		Qprime = Q(i, :)';
		GPqTable = [GPqTable, table(Qprime)]; %#ok
		
		GPq = fitrgp(GPqTable, 'Qprime', 'KernelFunction', 'squaredexponential');
		
		% Compute Optimal Policy for i using the estimated GP
		options = optimoptions(@simulannealbnd, 'Display', 'off');
		Uopt = simulannealbnd(@(u) predict(GPq, [Xobs(:, i), u]), mean(UjRange, 2)', UjRange(:,1)', UjRange(:,2)', options);
		Uhats(:, i) = Uopt';
	end
	
	% Approximate the policy using a Gaussian Process
	for j = 1 : numVars
		piStar{j} = fitrgp(Xobs', Uhats(j, :)', 'KernelFunction', 'squaredexponential');
	end
	
	% Compute the KL divergence difference
	iterations = iterations+1;
end

end

