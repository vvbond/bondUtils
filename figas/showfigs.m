function showfigs(varargin)
% Show (hided) figures
%
% Usage: showFigs
%        showFigs(figHandles)
% _______________________________________________________________________ %

error(nargchk(0,1,nargin));
if nargin > 0
   figs = varargin{1}; 
else
    figs = sort(get(0,'Children'));
end
N = length(figs);
for ii=1:N
    figure(figs(ii));
end