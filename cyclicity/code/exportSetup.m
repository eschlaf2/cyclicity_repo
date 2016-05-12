function [s] = exportSetup(varargin)
ss = length(varargin);
switch ss
    case 1
        ColorSet = varycolor(varargin{1});
        outFormat = 'png';
    case 0 
        ColorSet = varycolor(5);
        outFormat = 'png';
    case 2
        if isempty(varargin{1})
            ColorSet = varycolor(5);
        else
            ColorSet = varycolor(varargin{1});
        end
        outFormat = varargin{2};
end

set(0,'DefaultAxesColorOrder',ColorSet);
set(0,'defaultAxesLineStyleOrder','-|--|:')

s = hgexport('readstyle','PowerPoint'); %'PowerPoint' for presentations
s.Format = outFormat;
s.FontSizeMin = '18';


%hgexport(gcf,'test',s);
