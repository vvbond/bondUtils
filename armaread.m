function A = armaread(fname, verbose)
% Read in a Armadillo matrix stored in a file in the arma_binary format .
%
% Usage: A = armaread(fname)
%
% INPUT:
%  fname    - name of the file.
%  verbose  - binary flag: 1 - display some info messages.
%
% OUTPUT:
%  A - output matrix.
%
% Examples:
%  armaread(fname);
%  [A]=armaread(fname);
%
% See also: <other funame>.
 
%% Created: 04-Jan-2016 10:36:38
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

%% Input check
% ToDo

if nargin == 1
    verbose = 0;
end

%% Read in the file header
fid = fopen(fname, 'r');
if fid==-1
    error(['Couldn''t open file: ' fname]);
end
% Read in two first lines:
l1 = fgetl(fid);
l2 = fgetl(fid);
if verbose
    disp(l1); disp(l2);
end
%% Parse the header
% Parse the data precision:
pstr = regexp(l1, 'ARMA_MAT_BIN_(FN|IU)(\d+)', 'tokens'); % number of bytes, string.
if isempty(pstr)
    fclose(fid);
    error('Error parsing file header: data precision couldn''t be determined');
end
ptype = pstr{1}{1};
pbyte = str2double(pstr{1}{2});
% MATLAB precision:
switch ptype
    case 'IU'
        switch pbyte
            case 4
                pcsn = 'uint32';
            case 8
                pcsn = 'uint64';
            otherwise
                error('Unknown precision width.');
        end
    case 'FN'
        switch pbyte
            case 4
                pcsn = 'single';
            case 8
                pcsn = 'double';
            otherwise
                error('Uknown precision width.');
        end
end
%% Parse the size of the matrix
size_str = regexp(l2, '(\d+)', 'tokens');
if isempty(size_str)
    fclose(fid);
    error('Error parsing file header: matrix size couldn''t be determined');
end
m = str2num(size_str{1}{1});
n = str2num(size_str{2}{1});

%% Read in the data
A = fread(fid, [m n], pcsn);
fclose(fid);