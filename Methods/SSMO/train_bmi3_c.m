function [ vbmi,u,D ] = train_bmi3_c( data,mask,l_training ,pa)
u = data(1:l_training,3:6);
u1 = u(4:l_training,1:4)';
u2 = u(3:l_training-1,1:4)';
u3 = u(2:l_training-2,1:4)';
U = [u1;u2;u3];
mU = mask(1:l_training,3:6);
mU(mU ~=-1) = 0;

mbmi = mask(1:l_training,7);
mbmi(mbmi~=-1) = 0;

vbmi = data(1:l_training,7);
Xp = [vbmi(4:end)';vbmi(3:end-1)';vbmi(2:end-2)';vbmi(1:end-3)'];

N = 5000;
yita1 = pa(1);
alpha1 = pa(2);
yita2 = pa(3);
alpha2 =pa(4);
delta1 = pa(5);
delta2 = pa(6);
%     yita1 = 0.4;
%     alpha1 = 0.04;
%     yita2 = 0.2;
%     alpha2 =0.04;
%     delta1 = 2;
%     delta2 = 3;
Ap = zeros(4,4);
Ap(4,4) = 1;
Bp = zeros(4,12);
Cp = zeros(4,size(Xp,2));
g_Xtemp = zeros(4,length(vbmi));
g_Utemp = zeros(12,length(vbmi));
obj = zeros(1,N);

for i = 1: N
	X = Xp(1:3,:);
	Y = [Xp(2:4,:);U;ones(1,size(U,2))];
	D = X*pinv(Y);
	
	obj(i) = 0.5*norm((X-D*Y).^2,'fro');
	
	Ap(1:3,2:4) = D(:,1:3);
	Bp(1:3,:) = D(:,4:end-1);
	Cp(1:3,:) = D(:,end)*ones(1,size(X,2));
	
	g_Xp = (eye(size(Ap,1))-Ap)'*((eye(size(Ap,1))-Ap)*Xp-Bp*U-Cp);
	g_Xtemp(1,4:end) = g_Xp(1,:);
	g_Xtemp(2,3:end-1) = g_Xp(2,:);
	g_Xtemp(3,2:end-2) = g_Xp(3,:);
	g_Xtemp(4,1:end-3) = g_Xp(4,:);
	g_x = ones(1,4)*g_Xtemp;
	tempx = vbmi - (yita1*g_x)';
	vbmi(mbmi == -1) = tempx(mbmi == -1);
	Xp = [vbmi(4:end)';vbmi(3:end-1)';vbmi(2:end-2)';vbmi(1:end-3)'];
	
	g_U = Bp'*(Bp*U+Cp-(eye(size(Ap,1))-Ap)*Xp);
	g_Utemp(1:4,4:end) = g_U(1:4,:);
	g_Utemp(5:8,3:end-1) = g_U(5:8,:);
	g_Utemp(9:12,2:end-2) = g_U(9:12,:);
	g_u = [eye(4),eye(4),eye(4)]*g_Utemp;
	tempu = u -(alpha1*g_u)';
	u(mU == -1) = tempu(mU==-1);
	u1 = u(4:l_training,1:4)';
	u2 = u(3:l_training-1,1:4)';
	u3 = u(2:l_training-2,1:4)';
	U = [u1;u2;u3];
	
	g_Xp = (eye(size(Ap,1))-Ap)'*((eye(size(Ap,1))-Ap)*Xp-Bp*U-Cp);
	g_Xtemp(1,4:end) = g_Xp(1,:);
	g_Xtemp(2,3:end-1) = g_Xp(2,:);
	g_Xtemp(3,2:end-2) = g_Xp(3,:);
	g_Xtemp(4,1:end-3) = g_Xp(4,:);
	g_x = ones(1,4)*g_Xtemp;
	tempx = vbmi - (yita2*g_x)';
	disX = TopNinMatrix(abs(tempx - data(1:l_training,7)),delta1);
	for j = 1:size(disX,1)
		vbmi(disX(j,2),disX(j,3)) = tempx(disX(j,2),disX(j,3));
	end
	Xp = [vbmi(4:end)';vbmi(3:end-1)';vbmi(2:end-2)';vbmi(1:end-3)'];
	
	g_U = Bp'*(Bp*U+Cp-(eye(size(Ap,1))-Ap)*Xp);
	g_Utemp(1:4,4:end) = g_U(1:4,:);
	g_Utemp(5:8,3:end-1) = g_U(5:8,:);
	g_Utemp(9:12,2:end-2) = g_U(9:12,:);
	g_u = [eye(4),eye(4),eye(4)]*g_Utemp;
	tempu = u -(alpha2*g_u)';
	disU = TopNinMatrix(abs(tempu-data(1:l_training,3:6)),delta2);
	for j = 1:size(disU,1)
		u(disU(j,2),disU(j,3)) = tempu(disU(j,2),disU(j,3));
	end
	u1 = u(4:l_training,1:4)';
	u2 = u(3:l_training-1,1:4)';
	u3 = u(2:l_training-2,1:4)';
	U = [u1;u2;u3];
	
end
%figure(2);
%semilogy(obj);



end

