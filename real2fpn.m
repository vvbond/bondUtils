function [m,e] = real2fpn(r,t)
% Return mantissa and exponent of a real number, 
% defined by a binary floating-point system with precision t
%
% Usage: [m,e] = real2fpn(r,t)
% INPUT:
% r         - real number
% t         - precision
% OUTPUT:
% m, e      - mantissa and exponent so that, r = m*2^(e-t)
%
% Examples: t=53; [m,e] = real2fpn(1,t), fpn(m,e,2,t)
%
% See also: fpn.

y = abs(r);
switch y
    case 0
        m = 0; e = 0;
        return;
    otherwise
        e = floor(log2(y)+1);
        m = y/2^(e-t);
end