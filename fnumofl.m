function l = fnumofl(fid)
% Return the number of lines in a text file.

%% Defaults:
bSize = 10e6;
l = 0;

%% Read through the file in blocks:
oldPosition = ftell(fid);
frewind(fid); % rewind to the beginning of the file.
while ~feof(fid)
    b = fread(fid, bSize, '*uchar');
    l = l + sum(b == 10);
end
l = l+1; % Compensate for the the last line in the file 
         % that do not have the 'new line' symbol.
fseek(fid, oldPosition, 'bof'); % go back to the old position in file.
    