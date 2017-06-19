function hax = gsuba()
% Get subaxes in the current figure.
%
% Usage: hax = gsuba()
%
% INPUT:
%  None.
%
% OUTPUT:
% hax - Array of subaxes handles.
%
% Examples:
%  gsuba();
%  [hax]=gsuba();
%
% See also: gaa, linkTheAxes.
 
%% Created: 19-Jun-2017 12:07:23
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

hax = findall(get(gcf,'Children'), 'Type', 'Axes');