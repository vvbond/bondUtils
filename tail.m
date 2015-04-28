function y = tail(x, k)
% Display last k lines of the input. 

% Defaults:
if nargin ==1 
    k = 10;
end

[m, n] = size(x);
switch nargout
    case 0
        if min(m,n)==1 % 1D matrix (i.e., a vector).
            disp(x(end-k+1:end));
        else
            disp(x(end-k+1:end,:));
        end
    case 1       
        if min(m,n)==1 
            y = x(end-k+1:end);
        else
            y = x(end-k+1:end,:);
        end
end