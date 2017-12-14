function subfig(fh, m, n, p)
% Position the given figure in the grid layout.
%
% Usage: subfig(fh, layout)
%
% INPUT:
% fh - .
% m, n - .
% p
%
% OUTPUT:
%  None.
%
% Examples:
%  subfig(fh, layout);
%  []=subfig(fh, layout);
%
% See also: <other funame>.
 
%% Created: 12-Dec-2017 10:37:45
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

    % Parse input:
    narginchk(4,4);
    if ~ishandle(fh), error('subfig: first argument must be a figure handle.'); end

    nRows = m;
    nCols = n;
    posIx = p;
    
    % Main:
    scrSz = get(0, 'ScreenSize');
    scrW = scrSz(3);
    scrH = scrSz(4);
    
    % Create grid:
    cellW = scrW/nCols;
    cellH = scrH/nRows;
    
    x = 1 + (0:nCols-1)*cellW;
    y = 1 + (0:nRows-1)*cellH;
    
    [X, Y] = meshgrid(x,fliplr(y));
    
    lowerL = [min(X(posIx)), min(Y(posIx))];
    upperR = [max(X(posIx)+cellW), max(Y(posIx)+cellH)];
    figPos = [lowerL, upperR-lowerL];
    set(fh, 'OuterPosition', figPos);
    
end