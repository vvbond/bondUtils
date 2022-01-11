function haxs = subplots(rows, cols)
% Generate subplots in the current figure.
%
% Usage: haxs = subplots(rows, cols)
%
% INPUT:
% raws - number of rows.
% cols - number of cols in the subplots grid.
%
% OUTPUT:
% haxs - handle to the resulting axes.
%
% Examples:
%  haxs = subplots(rows, cols);
%
% See also: subfig.
 
%% Created: 10-Jan-2022 14:57:31
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

haxs = arrayfun(@(i) subplot(rows, cols, i), 1:rows*cols);
