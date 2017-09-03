function [bmi] = predict_bmi3_c( D,vbmi,u,data,l_training,l_testing,range )
    tbmi = [vbmi;data(l_training+1:l_training+l_testing,7)];
    tu = [u;data(l_training+1:l_training+l_testing,3:6)];
    tu1 = tu(4:l_training+l_testing,1:4)';
    tu2 = tu(3:l_training+l_testing-1,1:4)';
    tu3 = tu(2:l_training+l_testing-2,1:4)';
%     range = 7;
    bmi = iterate_bmi3(tbmi,D,4,l_training+l_testing,range,tu3,tu2,tu1);

   % error = norm(bmi-tbmi)^2/(l_training+l_testing);
%     
% 
%     s2 = iterate_bmi3( tbmi,D, 4, l_training, range,tu3,tu2,tu1 );
%     error2 = norm(s2 - tbmi(1:l_training))^2/l_training;
%     
% 
%     s3 = iterate_bmi3( tbmi(l_training:end),D, 4, l_testing+1, range,tu3,tu2,tu1 );
%     error3 = norm(s3 - tbmi(l_training:l_training+l_testing))^2/l_testing;
%     

end

