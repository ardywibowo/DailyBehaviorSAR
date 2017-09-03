function [list,value,nvalue] = raw_data_separation(s)
% s : name of the data file.
%output data which is normalized. list is the new dataset separation.
	data = load(s);

    list = list_generator(data);
    m = importdata('data_collect.mat');
    value = [];
    for i = 1:length(m)
        value = [value;data(list(m(i))+1:list(m(i)+1),:)];
    end

    nvalue = value;

    for j = 3:7
        p = nvalue(:,j);
        p(p == -1) = mean(p(p~=-1));
        nvalue(:,j) = p;
    end
%     data = minMaxMap(data')';

    list = list_generator(nvalue);
    nvalue = minMaxMap(nvalue')';
end
