function [ s ] = iterate_bmi3( tbmi,D, start, ending, range,tu1,tu2,tu3 )
%
    s = zeros(ending,1);
    s(1:3) = tbmi(1:3);
    
    for i = start:ending
        if mod(i-4,range) == 0
            y = D*[tbmi(i-1:-1:i-3);tu3(:,i-3);tu2(:,i-3);tu1(:,i-3);1];
            s(i) = y(1);
        else 
            if mod(i-4,range) == 1
                y = D*[s(i-1);tbmi(i-2:-1:i-3);tu3(:,i-3);tu2(:,i-3);tu1(:,i-3);1];
                s(i) = y(1);
                s(i-1) = y(2);
            else
                if mod(i-4,range) == 2
                    y = D*[s(i-1:-1:i-2);tbmi(i-3);tu3(:,i-3);tu2(:,i-3);tu1(:,i-3);1];
                    s(i) = y(1);
                    s(i-1) = y(2);
                    s(i-2) = y(3);
                else
                    y = D*[s(i-1:-1:i-3);tu3(:,i-3);tu2(:,i-3);tu1(:,i-3);1];
                    s(i) = y(1);
                    s(i-1) = y(2);
                    s(i-2) = y(3);
                end
            end
        end
    end
end

