clear all;
clc;
close all;

[d,v] = raw_data_separation('orig139.tsv');

%m1 = [69,71,73,77,81,87,88,97,99,100];
rr = 10;%choose the aim person's id
for i = rr
    vlen = d(i+1) - d(i);
    temp = v(d(i)+1:d(i)+vlen,:);
    for j = 1:7
        p=temp(:,j);
        %p(p==-1) = mean(p(p~=-1));
        p(p==-1) = NaN;
        temp(:,j) = p;
    end
    f=figure;
    N =50;
    plot(temp(1:N,7),'ko-','MarkerEdgeColor','b','MarkerFaceColor','y','Linewidth',3,'MarkerSize',6);
    %for j =[3:6, 8:18,25,37,39]
    for j =[3:6, 8:18,25,37,39]
        hold on;
        plot([j,j],[28,29.5],'r','LineWidth',1);
        plot([j,j],[30.5,35],'r','LineWidth',1);
    end
    %title('Outliers and Missing value of BMI during 50 days');
    x1 = find(min(temp(1:N,7))==temp(1:N,7))+1;
    y1 = min(temp(1:N,7));
    str1 = '\Leftarrow Outlier';
    text(x1,y1,str1,'HorizontalAlignment','left','FontSize',15);
    text(9,30,'Missing Value','FontSize',15)
    axis([0 N 26 35]);
    grid on;
    grid minor;
    
    xlabel('Days');
    ylabel('BMI');
    set(gca,'FontSize',15);
    set(gcf, 'PaperPosition', [0 0 10 5]); %Position plot at left hand corner with width 5 and height 5.
    set(gcf, 'PaperSize', [10 5]); %Set the paper to have width 5 and height 5.
    saveas(gcf, strcat(num2str(i),'_OutlierAndMissingValue'), 'pdf') %Save figure
end
