function s = strucat(s1, s2)
% Conctatenate two structures by concatenating their fields.
%
% Usage: s = strucat(s1, s2)
%
% INPUT:
% s1 - the 1st structure.
% s2 - the 2nd structure: s2 must have the same fields as the s1..
%
% OUTPUT:
% s - resulting structure with the fields being vertically concatenated fields of s1 and s2..
%
% Examples:
%  strucat(s1, s2);
%  [s]=strucat(s1, s2);
%
% See also: <other funame>.
 
%% Created: 05-Mar-2015 15:24:52
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

%% Parse input:
if ~(isstruct(s1)||isempty(s1) && isstruct(s2)||isempty(s2))
    error('Input arguments must be structures.');
end

ss = [s1 s2]; % create array of structures.

if length(ss)==1
    s = ss;
else
    fieldNames = fieldnames(ss);
    for ii=1:length(fieldNames)
        s.(fieldNames{ii}) = vertcat(ss(:).(fieldNames{ii}) );
    end    
end
