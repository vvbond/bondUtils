function varargout = drawPolygon(varargin)
% Draw an N-points polygon in the xy-plane.
%
% Usage:    drawPolygon([p1, p2, ..., pN])
%           drawPolygon(..., 'lType')
%
% INPUT:
%  [p1, p2, ..., pN]   - 2-by-N matrix of  [x; y] coordinates of the N corner points.
% (optional)
% 'lType'  - a string defining the line style and width (e.g., '2r-.').
%             Default: 'b-'.
%
% OUTPUT:
% none
%
% Examples in 2D:
%  figure, drawPolygon([1 2 3 4 5; 1 2 3 4 5]);
%
% See also: drawRect, drawCircle, drawSphere, drawPlane, drawVector, drawLine, drawXLine, drawYLine.

% Copyright (c) 2017, Vladimir Bondarenko.

% Check input:
narginchk(2,3);

% Defaults:
lType = 'k-';
hax = []; P = [];

% Parse input:
for ii=1:nargin
    val = varargin{ii};
    if isnumeric(val)
        P = val;
    elseif ischar(val)
        lType = varargin{ii};
    elseif ishandle(val)
        hax = val;
    else
        error('drawPolygon: unknown parameter type.');
    end
end

% Check input:
if size(P,1) ~= 2, error('drawPolygon: number of rows in the input must be 2, corresponding to (x; y) coordinates.'); end
% Parse the line parameters
[lStyle,lWidth,lColor, lMarker] = parseLineType(lType);
if isempty(hax), hax = gca; end
    
% MAIN:
holdon = get(hax, 'NextPlot');          % Capture the NextPlot property.
x = P(1, [1:end 1]);
y = P(2, [1:end 1]);
gca; hold on;
varargout{1} = line(hax, x, y, 'LineStyle', lStyle, ...
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