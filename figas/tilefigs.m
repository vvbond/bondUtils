function tilefigs(varargin)
% Tile figure in 2 columns and several rows
% 
% Usage: tileFigs()
%        tileFigs(nrows)
%        tileFigs(nrows, figHandles)
% ________________________________________________________________________

narginchk(0,2);

ncols = 2;      % Number of columns is fixed.
% Set the number of rows
if nargin == 2
   figHandles = varargin{2};
else
    figHandles = sort(get(0,'Children'));
end
N = length(figHandles);
if nargin > 0
    nrows = varargin{1};
else
    nrows = ceil(N/ncols);
    if nrows==1
        nrows = 2;
    end
end

tuneH = 1;
tuneW = 0;

scrsz = get(0,'ScreenSize');
width = scrsz(3)/(ncols)-tuneW;
height = scrsz(4)/(nrows*tuneH);
bottom = scrsz(4) - (1:nrows)'*height*tuneH;
left = 1 + (0:ncols-1)*(width+tuneW);

b = repmat(bottom, ncols, 1);
l = repmat(left, nrows, 1);

for ii=1:N
    k = mod(ii-1, nrows*ncols)+1;
    set(figHandles(ii), 'Position', [l(k) b(k) width height]);
end