function hax = gsuba(hfig)
% Get subaxes handles in a given figure.
%
% Usage: hax = gsuba()
%        hax = gsuba(hfig)
% INPUT:
% Optional:
%  hfig     - figure handle. If omitted, the current figure is used.
%
% OUTPUT:
%  hax      - Array of subaxes handles.
%
% Examples:
%  gsuba();
%  hax = gsuba();
%
% See also: gaa, linkTheAxes.
 
%% Created: 19-Jun-2017 12:07:23
%% (c) Vladimir Bondarenko, http://www.mathworks.co.uk/matlabcentral/fileexchange/authors/52876

if nargin == 0
    hfig = gcf;
end
hax = findall(get(hfig,'Children'), 'Type', 'Axes');