function [ fdata ] = OutlierFilter( data )
%
    fdata = data;
    for i = size(data,2)
        fdata(:,i) = medfilt1(data(:,i),4);
    end


end

