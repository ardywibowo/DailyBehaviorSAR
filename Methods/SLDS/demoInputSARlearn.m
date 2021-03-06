% function demoSARlearn
%DEMOSARLEARN demo of learning in a Switching Autoregressive Model
clear; close all; clc;
addpath('../../BRMLtoolkit');
import brml.*
S = 4; % number of Hidden states
L = 2; % order of each AR model
T = 100; % length of the time-series
Tskip=10;

x=1:T;
for s=1:S
	% generate a sequence and get the AR coeffs by fitting the sequence:
	y=sin(1*x*rand)+0.01*randn(1,T); a_true(:,s) = ARtrain(y,L);
end
stran_true = condp(rand(S,S)+1*eye(S)); % switch transition
sprior_true=condp(ones(S,1)); % switch prior
sigma2_true=0.01*ones(1,S);

% generate some training data:
x=randn(1,T); % random initial visible variable
current_u=randn(1,T); % random initial visible variable
s_true(1)=randgen(sprior_true); % random initial switch state
for t=2:T
	Lt = min(t-1,L); % to handle the start when not enough timepoints exist
	vhat = x(t-Lt:t-1)';
	if mod(t,Tskip)==0
		s_true(t) = randgen(stran_true(:,s_true(t-1)));
	else
		s_true(t)=s_true(t-1);
	end
	x(t)=a_true(1:Lt,s_true(t))'*vhat+sqrt(sigma2_true(s_true(t)))*randn;

	vhat = current_u(t-Lt:t-1)';
	current_u(t)=a_true(1:Lt,s_true(t))'*vhat+sqrt(sigma2_true(s_true(t)))*randn;
end

u = cell(1);
u{1} = current_u;

v = x;
for i = 1 : length(u)
	current_u = u{i};
	v = v + current_u;
end

st=zeros(S,T);for t=1:T; st(s_true(t),t)=1; end % (for plotting later)
figure(1); subplot(2,1,1); plot(v,'k');  hold on; c=hsv(S);
title('sample switches')
for s=1:S
	tt=find(s_true==s);
	plot(tt,v(tt),'.','color',c(s,:));
end

% EM training:
figure
opts.plotprogress=1;
opts.maxit=30;
opts.stran=stran_true;
opts.sigma2=sigma2_true;
[a,b,sigma2,stran,phtgV1T]=inputSARLearn(v,u,L,L,S,Tskip,opts);

[val ind]=max(phtgV1T); % find the most likely MPM switches
figure(1);
subplot(2,1,2); plot(v,'k'); hold on; title('learned switches')
for s=1:S
	tt=find(ind==s);
	plot(tt,v(tt),'.','color',c(s,:));
end