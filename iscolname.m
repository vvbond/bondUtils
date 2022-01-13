function tf = iscolname(T, colname)
% Returns true if a column with given name exists in a table.
%
% Usage: tf = iscolname(T, colname)
%
% INPUT:
%  T - table.
%  colname - column name.
%
% OUTPUT:
%  tf - true or false.
%
% Examples:
%  iscolname(T, varname);
%
% See also: isfield, isprop.
 
%% Created: 13-Jan-2022 18:36:35
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

tf = any(ismember(T.Properties.VariableNames, colname));