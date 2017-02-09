function figsz(varargin)
% Set the size of current figure.


%% Parse input
narginchk(1,2);

if nargin==1
    fh = gcf;
    sz = varargin{1};
else
    fh = varargin{1};
    sz = varargin{2};
end

%% Main
scrsz = get(0, 'ScreenSize');
scrwth = scrsz(3); scrht = scrsz(4);
fpos = get(fh, 'Position');

if isnumeric(sz)
    fpos(3:4) = sz; 
else
    switch sz
        case 'full'
            fpos(3:4) = [scrwth scrht];
        case 'quarter'
            fpos(3:4) = [scrwth scrht]/2;
        case 'half'
            fpos(3:4) = [scrwth/2 scrht];
        otherwise
            error('Uknown size parameter.');
    end   
end

set(fh, 'Position', fpos);
        
    
    
