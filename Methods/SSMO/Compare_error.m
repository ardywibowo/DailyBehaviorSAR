clear all;
clc;
close all;
addpath('./model');
[d,v,nv] = raw_data_separation('orig139.tsv');

vla = importdata('range_bmi.mat');
load('model3/xcuc.mat');

rr = 1:24;
%rr = 13;
error = zeros(6,length(rr));
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
    
        bmi1 = importdata(strcat('model/bmi1_',num2str((i-1)*100+m(i,1)*10+m(i,2)),'.mat'));
        bmi2 = importdata(strcat('model3/bmi2_',num2str(i-1),'.mat'));
        bmi3 = importdata(strcat('model3/bmi3_',num2str(i-1),'.mat'));

        bmi1_train = bmi1(1:length(rbmi_train));
        bmi2_train = bmi2(1:length(rbmi_train));
        bmi3_train = bmi3(1:length(rbmi_train));

        bmi1_test = bmi1(length(rbmi_train)+1:end);
        bmi2_test = bmi2(length(rbmi_train)+1:end);
        bmi3_test = bmi3(length(rbmi_train)+1:end);

        error(1,i) = mean(abs(bmi1_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
        error(2,i) = mean(abs(bmi2_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
        error(3,i) = mean(abs(bmi3_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
        error(4,i) = var(abs(bmi1_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
        error(5,i) = var(abs(bmi2_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
        error(6,i) = var(abs(bmi3_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
	minimume = error(1,i);
	fprintf('%f\t%f\t%f\t%f\t%f\t%f\n',minimume,error(4,i),error(2,i),error(5,i),error(3,i),error(6,i));
    
    close all;
    figure(1);
    plot(convert_range( whole(:,7),vla),'r');
    hold on;
    plot(convert_range(bmi1,vla),'b');
    hold on;
    plot(convert_range(bmi2,vla),'g');
    hold on;
    plot(convert_range(bmi3,vla),'m');
    hold on;
    
    xlabel('Days');
    ylabel('BMI');
    
    title('BMI prediction');
    legend('Real BMI','Missing and Outliers Estimation Simultaneously','Missing with mean value','Missing with previous value');
     set(gca,'FontSize',15);
    set(gcf, 'PaperPosition', [0 0 10 5]); %Position plot at left hand corner with width 5 and height 5.
    set(gcf, 'PaperSize', [10 5]); %Set the paper to have width 5 and height 5.
    saveas(gcf, strcat('model3/bmi',num2str(i),'xc',num2str(0),'uc',num2str(0)), 'pdf') %Save figure
 
    
end
% 
% save(strcat('model2/error','.mat'),'error');
