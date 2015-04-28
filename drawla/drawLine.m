function varargout = drawLine(a, b, lType)
% Draw a 2D line, y=ax+b, in the current axis.
%
% Usage: drawSegment(Points)
%        drawSegment(Points, lType)
%        hLine = drawSegment(Points, lType)
%
% INPUT:
%  a        - line slope, a scalar.
%  b        - intercept
% (optional parameters)
%  lType         - string specifying line color, style and width, and
%                 the marker, e.g., 'r2--*'.
%                 Default: 'k1--' (no marker);
%
% OUTPUT:
% (optional output): handle to the line object.
%
% Examples:
%
% See also: drawSegment, drawVector, drawPlane, drawSpan, drawMesh.

% Copyright (c) 2009, Dr. Vladimir Bondarenko <http://sites.google.com/site/bondsite>

% Check input for sanity:
error(nargchk(2,3,nargin));
error(nargoutchk(0,1,nargout));
% Parse the input:
if nargin==2 
    lColor = 'k'; lStyle = '--'; lWidth = 1; lMarker = 'none';
else
    if ~ischar(lType), error('Wrong input: lType must be a string.');end
    % Parse the lType string
    % get line style
    lStyles = '--|:|-\.|-';
    [dum1,dum2,dum3, lStyle] = regexp(lType, lStyles, 'once');
    if isempty(lStyle), lStyle = '--'; end
    % get width
    [dum1,dum2,dum3, lWidth] = regexp(lType, '\d*', 'once');
    if isempty(lWidth), lWidth = 1; else lWidth = str2double(lWidth); end
    % get color
    lColors = 'y|m|c|r|g|b|w|k';
    [dum1,dum2,dum3, lColor] = regexp(lType, lColors, 'once');
    if isempty(lColor), lColor = 'k'; end
    % get marker
    lMarkers = '\+|o|\*|\.|x|s|d|\^|>|<|v|p|h|';
    [dum1,dum2,dum3, lMarker] = regexp(lType, lMarkers, 'once');
    if isempty(lMarker), lMarker = 'none'; end
end

% Plot the line
dim = 2;
switch dim
    case 2
        xData = xlim';
        yData = [xData ones(2,1)]*[a;b];
        hLine = line(xData, yData, 'LineStyle', lStyle, ...
                                   'LineWidth', lWidth, ...
                                   'Color'    , lColor, ...
                                   'Marker'   , lMarker     );
    case 3
%         xData = Points(1,:);
%         yData = Points(2,:);
%         zData = Points(3,:);
%         hLine = line(xData, yData, zData, ...
%                                    'LineStyle', lStyle, ...
%                                    'LineWidth', lWidth, ...
%                                    'Color'    , lColor, ...
%                                    'Marker'   , lMarker     );
    otherwise
        error('Wrong dimensions of the input parameter.');
end
if nargout, varargout{1} = hLine; end