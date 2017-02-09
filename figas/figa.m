function figa(varargin)
% Creates a figure with a given name
%
% Usage: figa(); 
%        figa(figNumber), 
%        figa(figNumber, figName)
%        figa(figNumber, figName, toolbar)
%        figa(figNumber, figName, toolbar, menubar)
%
% INPUT:
% figNumber :    an integer
% figName   :    a string
% toolbar   :    { {none}, auto, figure }         
% menubar   :    { {none}, figure }
%
% See also: figManager.

% Defaults:
figParam = cell(1,4);
figParam{1} = 0;
figParam{2} = '';
figParam{3} = 'none';
figParam{4} = 'none';

% Parse input arguments
error(nargchk(0,3, nargin));
if nargin > 0
    figParam(1:nargin) = varargin;
    h = figure(figParam{1});
else
    h = figure;
end

set(h, 'Name', figParam{2}, 'Toolbar', figParam{3}, 'Menubar', figParam{4});
