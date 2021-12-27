function p = scrctr(w, h)
% Get screen center point.
%
% Usage: p = scrctr()
%
% INPUT:
%  Optional:
%   w - width
%   h - height
%
% OUTPUT:
% p - 2-vector specifying the position of the screen center point or 
%     4-vector definging the postion of the centered rectangle of given width and height.
%
% Examples:
%  scrctr();
%  [p]=scrctr();
%
% See also: scrh(), scrw().
 
%% Created: 14-Dec-2021 17:55:03
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876
narginchk(0,2);
dum = get(0,'ScreenSize');
p = dum(3:4)/2;

if nargin == 0
    return;
elseif nargin == 1
    h = w;
end
p = [p-[w, h]/2, w, h];

end

