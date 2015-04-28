function c = strsplit1(s, delim)
% Custom strsplit. 
% 
% Simpler (and less robust) but faster then strsplit. 

% Get the ascii code of the delimiter:
switch delim
    case '\t'
        delim_ascii = 9;
    case '\n'
        delim_ascii = 10;
    otherwise
        delim_ascii = double(delim);
end

dix = find(double(s) == delim_ascii); % vector of delimiter positions.
dix = [0 dix length(s)+1]; % augment the vector by the first and last index.
nval = length(dix)-1;
c = cell(1,nval);
for ii=1:nval
    c{ii} = s(dix(ii)+1:dix(ii+1)-1);
end