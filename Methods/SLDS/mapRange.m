function mapped = mapRange(original, range)
%MAPRANGE Maps values to the specified range
% mapped = mapRange(original, range)
% Inputs:
% original : Input vector of data
% range    : New specified range
% 
% Output:
% mapped: Mapping of original values in new range

mapped = (original * (range(1)-range(2)) + range(1)+range(2)) / 2;

end

