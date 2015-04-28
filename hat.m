function varargout = hat(x, nh, nt)
% Head and tail display.
%
% Usage: hat(x)
%        [hd, tl] = hat(x, k)
%        [hd, tl] = hat(x, k1, k2)
%
% INPUT:
%   x - vector or a matrix.
%  Optional:
%   nh - number of head lines, default 10.
%   nt - number of tail lines, default 10.
%
% OUTPUT:
%  Display the first and the last k lines of the input.
%
% Examples:
%  hat(rand(100,10));
%  hat(rand(100,10), 5);
%  [ hd, tl ] = hat(rand(100,10), 5);
%  [ hd, tl ] = hat(rand(100,10), 3, 5);
%
% See also: head(), tail().
 
%% Created: 25-Feb-2015 13:01:28
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

%% Check number of input/output arguments:
narginchk(1,3);
nargoutchk(0,2);

%% Parse input:
switch nargin
    case 1
        nh = 10;
        nt = 10;
    case 2
        nt = nh;
end

%% Main:
if nargout == 0
    head(x, nh);
    disp('       :'); 
    disp('       :');
    tail(x, nt);
else
    funs = {@(y) head(y, nh), @(y) tail(y, nt)};
    for ii=1:nargout
        varargout{ii} = funs{ii}(x);
    end
end