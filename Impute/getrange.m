clear all;
clc;
close all;
addpath('./modeldata');
[d,v,nv] = raw_data_separation('orig139.tsv');
nvalue = v;
    
for j = 3:7
     p = nvalue(:,j);
     p(p == -1) = mean(p(p~=-1));
     nvalue(:,j) = p;
end

maxu1 = [max(nvalue(:,3)),min(nvalue(:,3))];
maxu2 = [max(nvalue(:,4)),min(nvalue(:,4))];
maxu3 = [max(nvalue(:,5)),min(nvalue(:,5))];
maxu4 = [max(nvalue(:,6)),min(nvalue(:,6))];
maxbmi = [max(nvalue(:,7)),min(nvalue(:,7))];

save('range/range_u1.mat','maxu1');

save('range/range_u2.mat','maxu2');
save('range/range_u3.mat','maxu3');
save('range/range_u4.mat','maxu4');
save('range/range_bmi.mat','maxbmi');