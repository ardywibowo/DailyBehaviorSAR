function [  ] = plot3status( X,s1,range1,s2,range2,s3,range3,ti ,error1,error2,error3,variance)
%
    figure;
    subplot(2,1,1);
    plot(X(range1),'r');
    hold on;
    plot(s1,'b');
    hold off;
    title(strcat(ti,'-training start; error = ',num2str(error1),'; variance = ',num2str(variance)));
    subplot(2,1,2);
    plot([X(range2);X(range3)],'r');
    hold on;
    plot([s2;s3],'b');
    hold off;
    title(strcat(ti,'-mid initialize the startpoint; error1 = ',num2str(error2),'; error2 = ',num2str(error3)));

end

