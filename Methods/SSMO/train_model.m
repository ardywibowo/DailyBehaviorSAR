function [ vbmi,u,D ] = train_model( d,v,nv,person )
% d: list of data partition
% v: data(time, id, exercise, food, workout c and workout time, bmi)
% person: aim
    close all;
    vlen = d(person+1) - d(person);
    data = v(d(person)+1:d(person)+vlen,:);
%     for j = 1:7
%         p=temp(:,j);
%         p(p==-1) = mean(p(p~=-1));
%         temp(:,j) = p;
%     end
    va = var(data(:,7));
%     data = minMaxMap(temp')';
    l_training = floor(vlen/2);
    l_testing = vlen-l_training;
    error = zeros(2,3);

    ti = strcat(num2str(person),'-3 days effect with constraints');
    [error(1,1),error(1,2),error(1,3),vbmi,u,D] = predict_bmi3_c(data,nv(d(person)+1:d(person)+vlen,:),l_training,l_testing,ti,va);
    [error(2,1),error(2,2),error(2,3)] = predict_bmi3(data,l_training,l_testing, 0,strcat(num2str(person),'-3 days effect'),va);

     print(figure(1),strcat('model/',ti),'-dpng');
     print(figure(2),strcat('model/',num2str(person),'-3 days effect'),'-dpng');
     save(strcat('model/',num2str(person),'vbmi.mat'),'vbmi');
     save(strcat('model/',num2str(person),'u.mat'),'u');
     save(strcat('model/',num2str(person),'D.mat'),'D');
     fprintf('%d th training complete\n',person);

end
