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
% p - Position of the screen center point or centered rectangle.
%
% Examples:
%  scrctr();
%  [p]=scrctr();
%
% See also: <other funame>.
 
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

