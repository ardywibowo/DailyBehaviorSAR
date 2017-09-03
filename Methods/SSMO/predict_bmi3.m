function [s] = predict_bmi3( data,D,l, d1,range )
%
%     range = 7;

    tbmi = data(d1+1:d1+l,7);

    tu1 = data(d1+4:d1+l,3:6)';
    tu2 = data(d1+3:d1+l-1,3:6)';
    tu3 = data(d1+2:d1+l-2,3:6)';
    s = iterate_bmi3(tbmi,D,4,l,range,tu1,tu2,tu3);

%    error1 = norm(status-tbmi)^2/(l_training+l_testing);
    
% 
%     s2 = iterate_bmi3( tbmi,D, 4, l_training, range,tu1,tu2,tu3 );
%     error2 = norm(s2 - tbmi(1:l_training))^2/l_training;
%     
% 
%     s3 = iterate_bmi3( tbmi(l_training:end),D, 4, l_testing+1, range,tu1,tu2,tu3 );
%     error3 = norm(s3 - tbmi(l_training:l_training+l_testing))^2/l_testing;
%     
%     plot3status(tbmi,status,1:l_training+l_testing,s2,1:l_training,s3(2:end),l_training+1:l_training+l_testing,ti,error1,error2,error3,variance);

    
end

