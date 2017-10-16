function varargout = drawRect(varargin)
% Draw a rectangle in xy-plane.
%
% Usage:    drawRect(x, y)
%           drawRect(x, y, 'lType')
%
% INPUT:
% x, y      - 2-vectors of [x1 x2] and [y1 y2] coordinates of diagonal corners for k rectangles.
% (optional)
% 'lType'  - a string defining the line style and width (e.g., '2r-.').
%             Default: 'b-'.
%
% OUTPUT:
% none
%
% Examples in 2D:
%  figure, drawRect([0 5], [0 3]);
%
% See also: drawCircle, drawSphere, drawPlane, drawVector, drawLine, drawXLine, drawYLine.

% Copyright (c) 2017, Vladimir Bondarenko.

% Check input:
narginchk(2,4);

% Defaults:
lType = 'k-';
hax = []; x = []; y = []; 

% Parse input:
for ii=1:nargin
    val = varargin{ii};
    if isnumeric(val)
        if isempty(x), x = val; else, y = val; end
    elseif ischar(val)
        lType = varargin{ii};
    elseif ishandle(val)
        hax = val;
    else
        error('drawRect: unknown parameter type.');
    end
end

% Check input:
if ~all(size(x)==size(y)), error('drawRect: Dimensions of p1 and p2 must be equal.'); end
% Parse the line parameters
[lStyle,lWidth,lColor, lMarker] = parseLineType(lType);
if isempty(hax), hax = gca; end
    
% MAIN:
holdon = get(hax, 'NextPlot');          % Capture the NextPlot property.
xx = [x(1) x(1) x(2) x(2) x(1)];
yy = [y(1) y(2) y(2) y(1) y(1)];
gca; hold on;
varargout{1} = line(hax, xx, yy, 'LineStyle', lStyle, ...
                                 'LineWidth', lWidth, ...
                                 'Color'    , lColor, ...
                                 'Marker'   , lMarker     );
set(hax, 'NextPlot', holdon);           % Restore the NextPlot property.


    function [lStyle,lWidth,lColor, lMarker] = parseLineType(lType)
    % Parse the line type
        % get line style
        lStyles = '--|:|-\.|-';
        [~,~,~, lStyle] = regexp(lType, lStyles, 'once');
        if isempty(lStyle), lStyle = 'none'; end
        % get width
        [~,~,~, lWidth] = regexp(lType, '\d*', 'once');
        if isempty(lWidth), lWidth = 1; else, lWidth = str2double(lWidth); end
        % get color
        lColors = 'y|m|c|r|g|b|w|k';
        [~,~,~, lColor] = regexp(lType, lColors, 'once');
        if isempty(lColor), lColor = 'k'; end
        % get marker
        lMarkers = '\+|o|\*|\.|x|s|d|\^|>|<|v|p|h|';
        [~,~,~, lMarker] = regexp(lType, lMarkers, 'once');
        if isempty(lMarker), lMarker = 'none'; end
    end
end