function saveFigure(directoryName)
%SAVEFIGURE Summary of this function goes here
%   Detailed explanation goes here

set(gcf, 'visible','off', 'CreateFcn', 'set(gcf,''visible'',''on'')');
saveas(gcf, [directoryName '.fig']);
saveas(gcf, [directoryName '.png']);
close;

end

