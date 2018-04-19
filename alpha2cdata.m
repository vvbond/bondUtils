function cdataOut = alpha2cdata(alpha, cdataIn)
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

if nargin == 1
    cdataIn = zeros(m,n,3);
elseif isa(cdataIn, 'uint8')
    cdataIn = double(cdataIn)/255;
end

cdataOut = zeros(m,n,3);
bg = ones(m,n,3);

ix = find(alpha == 0);
for k=1:3
    cdataOut(:,:,k) = alpha.*cdataIn(:,:,k) + (1 - alpha).*bg(:,:,k);
    cdataOut(ix+(k-1)*m*n) = nan;
end