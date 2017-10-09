function printify(hfig, labelSize, titleSize)
% Make a figure look good for printing.
%
% Usage: printify(hfig)
%        printify
%
% INPUT:
%  hfig         - handle to a figure. If omitted, use current figure.
%  labelSize    - Default, 14.
%  titleSize    - Default, 16.
%
% OUTPUT:
%  None.
%
% Examples:
%  figure, plot(randn(100,1), '.-'); xlabel('Time [units]'), ylabel('Value [units]');
%  printify
%
% See also: <other funame>.
 
%% Created: 05-Oct-2017 12:14:21
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

    % Defaults:
    labelSize_default = 16;
    titleSize_default = 18;
    % Parse input:
    narginchk(0,3);
    switch nargin
        case 0 
            hfig = gcf;
            labelSize = labelSize_default;
            titleSize = titleSize_default;
        case 1
            labelSize = labelSize_default;
            titleSize = titleSize_default;
        case 2
            titleSize = titleSize_default;
    end
    
    % Main:
    haxs = findall(get(hfig, 'Children'), 'Type', 'Axes');
    for ix = 1:length(haxs)
        hax = haxs(ix);
        hax.XLabel.FontSize = labelSize;
        hax.YLabel.FontSize = labelSize;
        hax.Title.FontSize = titleSize;
    end
end
