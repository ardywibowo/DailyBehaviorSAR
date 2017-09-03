function [ D ] = train_bmi3( data,l_training,d1 )
%
    vbmi = data(d1+1:d1+l_training,7);
    u1 = data(d1+4:d1+l_training,3:6)';
    u2 = data(d1+3:d1+l_training-1,3:6)';
    u3 = data(d1+2:d1+l_training-2,3:6)';
    Y = [vbmi(d1+3:end-1)';vbmi(d1+2:end-2)';vbmi(d1+1:end-3)';u3;u2;u1;ones(1,size(u3,2))];
    X = [vbmi(d1+4:end)';vbmi(d1+3:end-1)';vbmi(d1+2:end-2)'];
    D = X*pinv(Y);

end

