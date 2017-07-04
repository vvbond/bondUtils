function w = scrw()
% Get screen width.
%
% Usage: w = scrw()
%
% INPUT:
%  None.
%
% OUTPUT:
% w - Screen width in pixels.
%
% Examples:
%  scrw();
%  w = scrw();
%
% See also: scrh.
 
%% Created: 04-Jul-2017 10:43:14
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

dum = get(0,'ScreenSize');
w = dum(3);