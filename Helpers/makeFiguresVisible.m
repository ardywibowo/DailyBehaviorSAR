function makeFiguresVisible()
%MAKEFIGURESVISIBLE Summary of this function goes here
%   Detailed explanation goes here

s = dir('*.fig');
fileList = {s.name};

for i = 1 : length(fileList)
	openfig(fileList{i}, 'visible');
	[~, name, ~] = fileparts(fileList{i});
	saveFigure(name);
end

end

