clear all;
clc;
close all;
addpath('./model');
[d,v,nv] = raw_data_separation('orig139.tsv');

vla = importdata('range_bmi.mat');

% % m = importdata('data_collect.mat');
% 
rr = 1:length(d)-1;
%rr = 13;
error = zeros(6,length(rr)*100);
range = 7;
a1 = 0;
a2 = 0;
a3 = 0;
for i = rr
    
    
    [ train,ntrain,test,ntest ] = selectperson( d,v,nv,i );
    %ntest = MissingFilling(ntest,test,'mean');
    whole = MissingFilling([ntrain;ntest],[train;test],'mean');
    %whole = [ntrain;ntest];
    ntrain = whole(1:size(ntrain,1),:);
    ntest = whole(1+size(ntrain,1):end,:);
    rbmi_train = ntrain(:,7);
    mbmi_train = train(:,7);
    rbmi_test = ntest(:,7);
    mbmi_test = test(:,7);
    
    ntrain1 = MissingFilling(ntrain,train,'mean');
    %ntrain1 = OutlierFilter(ntrain1);
    D2 = train_bmi3(ntrain1,size(train,1),0);
    bmi2 = predict_bmi3(whole,D2,size(whole,1),0,range);
%     error(2) = error(2) + norm(bmi2 - whole(:,7));

    ntrain2 = MissingFilling(ntrain,train,'previous');
    %ntrain2 = OutlierFilter(ntrain2);
    D3 = train_bmi3(ntrain2,size(train,1),0);
    bmi3 = predict_bmi3(whole,D3,size(whole,1),0,range);
%     error(3) = error(3) + norm(bmi3 - whole(:,7));

    fprintf('xc=%d,uc=%d\n',0,0);

%     [vbmi,u,D1] = train_bmi3_c( ntrain,train,size(train,1),[0.4,0.02,0.2,0.02,0,0]);
%     bmi1 = predict_bmi3_c( D1,vbmi,u,whole,size(train,1),size(test,1),range);
%     error(1) = error(1) + norm(bmi1 - whole(:,7));
    close all;
    figure(1);
    plot(convert_range( whole(:,7),vla),'r');
    hold on;
%     plot(convert_range(bmi1,vla),'b');
%     hold on;
    plot(convert_range(bmi2,vla),'g');
    hold on;
    plot(convert_range(bmi3,vla),'m');
    hold on;
    
    xlabel('Days');
    ylabel('BMI');
    
    title('BMI prediction');
    legend('Real BMI','Missing and Outliers Estimation Simultaneously','Missing with mean value','Missing with previous value');
    
    
%     bmi1_train = bmi1(1:length(rbmi_train));
    bmi2_train = bmi2(1:length(rbmi_train));
    bmi3_train = bmi3(1:length(rbmi_train));
    
%     bmi1_test = bmi1(length(rbmi_train)+1:end);
    bmi2_test = bmi2(length(rbmi_train)+1:end);
    bmi3_test = bmi3(length(rbmi_train)+1:end);

%     save(strcat('model3/D1_',num2str((i-1)),'.mat'),'D1');
%     save(strcat('model3/vbmi',num2str((i-1)),'.mat'),'vbmi');
%     save(strcat('model3/u',num2str((i-1)),'.mat'),'u');
    save(strcat('model4/D2_',num2str((i-1)),'.mat'),'D2');
    save(strcat('model4/D3_',num2str((i-1)),'.mat'),'D3');
%     save(strcat('model3/bmi1_',num2str((i-1)),'.mat'),'bmi1');
    save(strcat('model4/bmi2_',num2str((i-1)),'.mat'),'bmi2');
    save(strcat('model4/bmi3_',num2str((i-1)),'.mat'),'bmi3');
    
    set(gca,'FontSize',15);
    set(gcf, 'PaperPosition', [0 0 10 5]); %Position plot at left hand corner with width 5 and height 5.
    set(gcf, 'PaperSize', [10 5]); %Set the paper to have width 5 and height 5.
    saveas(gcf, strcat('model4/bmi',num2str(i),'xc',num2str(0),'uc',num2str(0)), 'pdf') %Save figure

    
end

%error = error/(length(d)-1);
save(strcat('model4/error','.mat'),'error');
