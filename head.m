function y = head(x, k)
% Display first k lines of the input.

% Defaults:
if nargin ==1 
    k = 10;
end

[m, n] = size(x);
switch nargout
    case 0
        if min(m,n)==1 % 1D matrix (i.e., a vector).
            disp(x(1:k));
        else
            disp(x(1:k,:));
        end
    case 1       
        if min(m,n)==1 
            y = x(1:k);
        else
            y = x(1:k,:);
        end
end