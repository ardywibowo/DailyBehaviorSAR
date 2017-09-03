clear; clc; close all;

addpath('./model');
addpath('./PACE');
addpath('./fdaM');

[d,v,nv] = raw_data_separation('orig139.tsv');

vla = importdata('range_bmi.mat');

rr = 1:length(d)-1;
error = zeros(16,length(rr)*100);
range = 7;
a1 = 0;
a2 = 0;
a3 = 0;

for i = rr(1 : numel(rr))
	disp(num2str(rr(i)));
	[ train,ntrain,test,ntest ] = selectperson( d,v,nv,i );
	whole = MissingFilling([ntrain;ntest],[train;test],'mean');
	ntrain = whole(1:size(ntrain,1),:);
	ntest = whole(1+size(ntrain,1):end,:);
	rbmi_train = ntrain(:,7);
	mbmi_train = train(:,7);
	rbmi_test = ntest(:,7);
	mbmi_test = test(:,7);
	
	%     ntrain1 = MissingFilling(ntrain,train,'mean');
	%     ntrain1 = OutlierFilter(ntrain1);
	%     D2 = train_bmi3(ntrain1,size(train,1),0);
	%     bmi2 = predict_bmi3(whole,D2,size(whole,1),0,range);
	%     error(2) = error(2) + norm(bmi2 - whole(:,7));
	
	%     ntrain2 = MissingFilling(ntrain,train,'previous');
	%     ntrain2 = OutlierFilter(ntrain2);
	%     D3 = train_bmi3(ntrain2,size(train,1),0);
	%     bmi3 = predict_bmi3(whole,D3,size(whole,1),0,range);
	%     error(3) = error(3) + norm(bmi3 - whole(:,7));
	
	ntrain1 = OutlierFilter(ntrain);
	ntrain1 = MissingFilling(ntrain1,train,'fda');
	D2 = train_bmi3(ntrain1,size(train,1),0);
	bmi2 = predict_bmi3(whole,D2,size(whole,1),0,range);
	bmi3 = bmi2;
	
	
% 	ntrain2 = OutlierFilter(ntrain);
% 	haarImputed = MissingFilling(ntrain2,train,'haar');
% 	ntrain2(train == -1) = haarImputed(train == -1);
% 	D3 = train_bmi3(ntrain2,size(train,1),0);
% 	bmi3 = predict_bmi3(whole,D3,size(whole,1),0,range);
	
	imputedData = csvread(strcat('PACE Imputed 2/', num2str(i), '.csv'));
	ntrain3 = ntrain;
	ntrain3 = OutlierFilter(ntrain3);
	ntrain3(train == -1) = imputedData(train == -1);
	
	D4 = train_bmi3(ntrain3,size(train,1),0);
	bmi4 = predict_bmi3(whole,D4,size(whole,1),0,range);
	error(4) = error(4) + norm(bmi4 - whole(:,7));
	
	
	for xc= 1:1
		for uc = 1:1
			fprintf('xc=%d,uc=%d\n',xc,uc);
			
			[vbmi,u,D1] = train_bmi3_c( ntrain,train,size(train,1),[0.4,0.02,0.2,0.02,xc,uc]);
			bmi1 = predict_bmi3_c( D1,vbmi,u,whole,size(train,1),size(test,1),range);
			
			close all;
			figure(1);
			plot(convert_range( whole(:,7),vla),'r');
			hold on;
			plot(convert_range(bmi1,vla),'b');
			hold on;
% 			plot(convert_range(bmi2,vla),'g');
% 			hold on;
% 			plot(convert_range(bmi3,vla),'m');
% 			hold on;
% 			plot(convert_range(bmi4,vla),'c', 'LineWidth', 2);
% 			hold on;
			
			xlabel('Days');
			ylabel('BMI');
			
			title('BMI prediction');
			legend('Real BMI','Missing and Outliers Estimation Simultaneously','Missing with mean value','Missing with previous value');
			
			
			bmi1_train = bmi1(1:length(rbmi_train));
			bmi2_train = bmi2(1:length(rbmi_train));
			bmi3_train = bmi3(1:length(rbmi_train));
			bmi4_train = bmi4(1:length(rbmi_train));
			
			bmi1_test = bmi1(length(rbmi_train)+1:end);
			bmi2_test = bmi2(length(rbmi_train)+1:end);
			bmi3_test = bmi3(length(rbmi_train)+1:end);
			bmi4_test = bmi4(length(rbmi_train)+1:end);
			
			error(1,(i-1)*100+xc*10+uc) = norm(bmi1_train(mbmi_train~=-1)-rbmi_train(mbmi_train~=-1))^2;
			error(2,(i-1)*100+xc*10+uc) = norm(bmi2_train(mbmi_train~=-1)-rbmi_train(mbmi_train~=-1))^2;
			error(3,(i-1)*100+xc*10+uc) = norm(bmi3_train(mbmi_train~=-1)-rbmi_train(mbmi_train~=-1))^2;
			error(4,(i-1)*100+xc*10+uc) = norm(bmi4_train(mbmi_train~=-1)-rbmi_train(mbmi_train~=-1))^2;
			
			error(5,(i-1)*100+xc*10+uc) = norm(bmi1_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1))^2;
			error(6,(i-1)*100+xc*10+uc) = norm(bmi2_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1))^2;
			error(7,(i-1)*100+xc*10+uc) = norm(bmi3_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1))^2;
			error(8,(i-1)*100+xc*10+uc) = norm(bmi4_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1))^2;
			
			error(9, (i-1)*100+xc*10+uc)  = mean(abs(bmi1_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
			error(10,(i-1)*100+xc*10+uc) = mean(abs(bmi2_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
			error(11,(i-1)*100+xc*10+uc) = mean(abs(bmi3_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
			error(12,(i-1)*100+xc*10+uc) = mean(abs(bmi4_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
			
			error(13,(i-1)*100+xc*10+uc) = var(abs(bmi1_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
			error(14,(i-1)*100+xc*10+uc) = var(abs(bmi2_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
			error(15,(i-1)*100+xc*10+uc) = var(abs(bmi3_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
			error(16,(i-1)*100+xc*10+uc) = var(abs(bmi4_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
			
%  		    fprintf('%f\t%f\t%f\t%f\t%f\t%f\n',ave1,ave2,ave3,var1,var2,var3);

			if i ~=13
				a1 = a1 + error(1,2);
				a2 = a2 + error(2,2);
				a3 = a3 + error(3,2);
			end


			save(strcat('analyticImputations/vbmi',num2str(rr(i)*100+xc*10+uc),'.mat'),'vbmi');
			save(strcat('analyticImputations/u',num2str(rr(i)*100+xc*10+uc),'.mat'),'u');

			save(strcat('analyticImputations/D1_',num2str(rr(i)*100+xc*10+uc),'.mat'),'D1');
			save(strcat('analyticImputations/D2_',num2str(rr(i)*100+xc*10+uc),'.mat'),'D2');
			save(strcat('analyticImputations/D3_',num2str(rr(i)*100+xc*10+uc),'.mat'),'D3');
			save(strcat('analyticImputations/D4_',num2str(rr(i)*100+xc*10+uc),'.mat'),'D4');

			save(strcat('analyticImputations/bmi1_',num2str(rr(i)*100+xc*10+uc),'.mat'),'bmi1');
			save(strcat('analyticImputations/bmi2_',num2str(rr(i)*100+xc*10+uc),'.mat'),'bmi2');
			save(strcat('analyticImputations/bmi3_',num2str(rr(i)*100+xc*10+uc),'.mat'),'bmi3');
			save(strcat('analyticImputations/bmi4_',num2str(rr(i)*100+xc*10+uc),'.mat'),'bmi4');
			save(strcat('analyticImputations/error','.mat'),'error');

			
			set(gca,'FontSize',15);
			set(gcf, 'PaperPosition', [0 0 10 5]); %Position plot at left hand corner with width 5 and height 5.
			set(gcf, 'PaperSize', [10 5]); %Set the paper to have width 5 and height 5.
			saveas(gcf, strcat('analyticImputations/bmi',num2str(rr(i)),'xc',num2str(xc),'uc',num2str(uc)), 'pdf') %Save figure
		end
	end
	%print(figure(1),strcat('model/bmi',num2str(i)),'-dpng');
	
	% disp(error);
	
end

%error = error/(length(d)-1);
