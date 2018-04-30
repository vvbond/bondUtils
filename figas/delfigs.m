function delfigs(varargin)
% Delete figures.
%
% Usage: delFigs
%        delFigs(figHandles)
% _______________________________________________________________________ %

narginchk(0,1);
if nargin > 0
   figs = varargin{1}; 
else
    figs = sort(get(0,'Children'));
end

for ii=1:length(figs)
    close(figs(ii))
end
