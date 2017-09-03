clear all;
clc;
close all;
addpath('./model');
[d,v,nv] = raw_data_separation('orig139.tsv');

vla = importdata('range_bmi.mat');

rr = 20;
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
    

    for xc= 1:10
        for uc = 1:10

    bmi1 = importdata(strcat('model/bmi1_',num2str((i-1)*100+xc*10+uc),'.mat'));
    bmi2 = importdata(strcat('model3/bmi2_',num2str((i-1)),'.mat'));
    bmi3 = importdata(strcat('model3/bmi3_',num2str((i-1)),'.mat'));
    
    bmi1_train = bmi1(1:length(rbmi_train));
    bmi2_train = bmi2(1:length(rbmi_train));
    bmi3_train = bmi3(1:length(rbmi_train));
    
    bmi1_test = bmi1(length(rbmi_train)+1:end);
    bmi2_test = bmi2(length(rbmi_train)+1:end);
    bmi3_test = bmi3(length(rbmi_train)+1:end);

    error(1,(i-1)*100+(xc-1)*10+uc) = mean(abs(bmi1_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
    error(2,(i-1)*100+(xc-1)*10+uc) = mean(abs(bmi2_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
    error(3,(i-1)*100+(xc-1)*10+uc) = mean(abs(bmi3_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
%     error(4,(i-1)*100+(xc-1)*10+uc) = std(abs(bmi1_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
%     error(5,(i-1)*100+(xc-1)*10+uc) = std(abs(bmi2_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
%     error(6,(i-1)*100+(xc-1)*10+uc) = std(abs(bmi3_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
    
%     error(1,(i-1)*100+(xc-1)*10+uc) = sqrt(norm(bmi1_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1))^2/sum(mbmi_test~=-1));
%     error(2,(i-1)*100+(xc-1)*10+uc) = sqrt(norm(bmi2_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1))^2/sum(mbmi_test~=-1));
%     error(3,(i-1)*100+(xc-1)*10+uc) = sqrt(norm(bmi3_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1))^2/sum(mbmi_test~=-1));
%     error(4,(i-1)*100+(xc-1)*10+uc) = std(abs(bmi1_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
%     error(5,(i-1)*100+(xc-1)*10+uc) = std(abs(bmi2_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
%     error(6,(i-1)*100+(xc-1)*10+uc) = std(abs(bmi3_test(mbmi_test~=-1)-rbmi_test(mbmi_test~=-1)));
        end
    end

    LinAlpha=0.25;           
    ColorValue=[1,0,0];
    
	minimume = min(error(1,(i-1)*100+1:i*100));
	fprintf('%f\t%f\t%f\n',minimume,error(2,(i-1)*100+1),error(3,(i-1)*100+1));
    %fprintf('%f\t%f\t%f\t%f\t%f\t%f\n',minimume,error(4,i),error(2,i),error(5,i),error(3,i),error(6,i));
    close all;
    figure(1);
    plot(convert_range(ntest(:,7),vla),'r-','Color',1.0-LinAlpha*(1.0-ColorValue),'EraseMode','xor','LineWidth',6);
    hold on;
    plot(convert_range(bmi2_test,vla),'b:','LineWidth',4);
    hold on;
    plot(convert_range(bmi3_test,vla),'m--','LineWidth',4);
    hold on;
    plot(convert_range(bmi1_test,vla),'k-','LineWidth',4);
    hold on;
    
    legend('Ture BMI','Mean+Med','Last+Med','SSMO','Location','EastOutside');
    set(gca,'FontSize',40);
    
    axis tight;
    xlabel('Days','fontsize',40,'Position',[95,22.2]);%[120,25.7] for 17 [110,25.7] for 12 [110,23.2] for 13
    ylabel('BMI','fontsize',40);
    
%     title('BMI Estimation with 3 Methods');
    
    set(gcf, 'PaperPosition', [-1 -0.5 30 5]); %Position plot at left hand corner with width 5 and height 5.
    set(gcf, 'PaperSize', [27 4.5]); %Set the paper to have width 5 and height 5.
    saveas(gcf, strcat('model2/bmi',num2str(i)), 'pdf'); %Save figure
    
end

%save(strcat('model2/error','.mat'),'error');
