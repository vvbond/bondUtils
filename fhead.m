function fhead(x, k)
% Display first k lines of a file.

% Defaults:
if nargin==1 
    k = 10;
end

switch ischar(x)
    case 0 % input is a vector.
        error('The file name should be a string.');
    case 1 % input is a file name.
        fid = fopen(x, 'r');
        userFormat = get(0,'FormatSpacing');
        format compact
        for ii=1:k
            s = fgetl(fid);
            disp(s);
        end
        fclose(fid);
        % Restore user's spacing settings:
        set(0,'FormatSpacing',userFormat);
end
