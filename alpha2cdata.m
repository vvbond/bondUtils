function cdata = alpha2cdata(alpha)
% Compute color given transparency values.
%
% Usage: cdata = alpha2cdata(alpha)
%
% INPUT:
% alpha - transparency.
%
% OUTPUT:
% cdata - output cdata.
%
% Examples:
%  alpha2cdata(alpha);
%  [cdata]=alpha2cdata(alpha);
%
% See also: <other funame>.
 
%% Created: 06-Feb-2018 12:29:40
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

if isa(alpha, 'uint8')
    alpha = double(alpha)/255;
end

[m,n] = size(alpha);
cdata = zeros(m,n,3);

ix = find(alpha == 0);
for k=1:3
    cdata(:,:,k) = 1 - alpha;
    cdata(ix+(k-1)*m*n) = nan;
end

