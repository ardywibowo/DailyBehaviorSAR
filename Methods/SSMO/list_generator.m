function [ list ] = list_generator( v )
%According the first column to separate different person and give the
%answer.

in = v(:,1);

	list = 0;
	flag = 1;
	for i = 1 : size(v,1)-1
	    if abs(in(i+1) - in(i)) > 100
	        list(flag+1) = i;
	        flag = flag + 1;
        end
    end


end
