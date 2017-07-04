function w = scrh()
% Get screen height.
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
%  scrh();
%  w = scrh();
%
% See also: scrw.
 
%% Created: 04-Jul-2017 10:44:14
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

dum = get(0,'ScreenSize');
w = dum(4);