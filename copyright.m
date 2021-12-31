function s = copyright()
% print my copyright string.
%
% Usage: copyright()
%
% INPUT:
%  None.
%
% OUTPUT:
%  None.
%
% Examples:
%  copyright();
%
% See also: .

%% Created: 31-Dec-2021 14:05:50
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

s = sprintf('Created: %s\n%s', datestr(now()), "(c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876");
if nargout == 0
    disp(s)
end