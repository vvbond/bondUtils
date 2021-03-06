function varargout = drawXLine(x, lType)
% Draw vertical line in xy-plane at given x value.
%
% Usage: drawXLine(y)
%        drawXLine(y, lType)
%        hLine = drawXLine(y, lType)
%
% INPUT:
% x             - scalar or vector of line(s) abscissa(s).
% (optional parameters)
% lType         - string specifying line color, style and width, and
%                 the marker, e.g., 'r2--*'.
%                 Default: 'k1--' (no marker);
%
% OUTPUT:
% (optional output): handle to the line object.
%
% Examples in 2D:
%  clf; drawVector([1 1]); hold on; drawXLine(1); hold off;
%  clf; drawCircle(0,0,1); hold on; drawXLine(.5); hold off;
% Example in 3D:
%  clf; drawVector([1 1 1]); hold on; drawXLine(1, '2r-.'); hold off;
%
% See also: drawYLine, drawVector, drawPlane, drawSpan, drawMesh, drawCircle.

% Copyright (c) 2009, Dr. Vladimir Bondarenko <http://sites.google.com/site/bondsite>

% Check input for sanity:
narginchk(1,2);
nargoutchk(0,1);

% Defaults:
if nargin==1, lType = 'k1--'; end

% MAIN:
ylims = ylim;
for ii=1:length(x)
    hLine(ii) = drawSegment([x(ii) x(ii); ylims], lType);
end

if nargout, varargout{1} = hLine; end
