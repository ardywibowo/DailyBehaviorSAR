function [a, bs, sigma2, stran, phtgX1T] = inputSARLearn(x, us, Lx, Lu, S, Tskip, opts)
%INPUTSARLEARN EM training of a Switching AR model
% [a, b, sigma2, stran, phtgV1T] = inputSARLearn(x, u, L, S, Tskip, opts)
%
% Inputs:
% x  :  a single timeseries is contained in the row vector x.
% us :  Cell vector. A single timeseries is contained in the row vector u.
% Lx and Lu :  order of the AR model 
% S : number of AR models.
% Tskip forces the switches to make a transition only at times t for mod(t,Tskip)==0
% opts.maxit
% opts.plotprogress
% 
% Outputs:
% a  : learned AR coefficients for x
% bs : Cell vector. Learned AR coefficients for u each cell corresponds to
%      different input variables
% sigma2 : learned innovation noise
% stran  : learned transition distribution
% phtgV1T : smoothed posterior p(h(t)|v(1:T))
import brml.*
a=condp(randn(Lx,S)); % set the AR coefficients

bs = cell(length(us),1);
for i = 1 : length(bs)
	bs{i}=condp(randn(Lu,S)); % set the AR coefficients
end

stran=condp(ones(S,S)); % switch transition
sprior=condp(ones(S,1)); % switch prior
sigma2=var(x)*ones(1,S);
T=size(x,2);

for emloop=1:opts.maxit
    % Inference using HMM structure:
    [logalpha, loglik]= HMMforwardInputSAR(x, us, stran, sprior, a, bs, sigma2, Tskip);
    logbeta = HMMbackwardInputSAR(x, us, stran, a, bs, sigma2, Tskip);
    [phtgX1T, phthtpgX1T] = HMMsmoothInputSAR(logalpha, logbeta, a, bs, sigma2, stran, x, us, Tskip);
    loglikem(emloop)=loglik;
    if opts.plotprogress; plot(loglikem); title('log likelihood'); drawnow; end
	for s=1:S
        vvhat_sum=zeros(Lx+Lu,1); vhatvhat_sum=zeros(Lx+Lu,Lx+Lu);
		sigma_sum=0; sigma_num=0;
		
		for t=1:T
			[m, xhat, uhat] = sarMean(x, us, t, a, bs, 0);
			m = m(s);
			vhat = [xhat; uhat];
			
            vvhat_sum = vvhat_sum + phtgX1T(s,t)*x(t)*vhat./sigma2(s);
            vhatvhat_sum = vhatvhat_sum + phtgX1T(s,t)*(vhat*vhat')./sigma2(s);
            sigma_sum = sigma_sum+phtgX1T(s,t)*(x(t)-m).^2;
            sigma_num = sigma_num + phtgX1T(s,t);
		end
		c = pinv(vhatvhat_sum)*vvhat_sum;
        a(:,s) = c(1:Lx);
		
		for i = 1 : length(bs)
			bs{i}(:,s) = c(Lx+1 + (i-1)*Lu : Lx + i*Lu);
		end
		
        sigma2(s)=sigma_sum/sigma_num;
	end
    t=1:T-1; tt=t(mod(t+1,Tskip)==0);
    stran=condp(sum(phthtpgX1T(:,:,tt),3)');
end

end

