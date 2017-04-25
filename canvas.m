function canvas(xscale, yscale)
    switch nargin
        case 0
            xscale = 10; yscale = 10; 
        case 1
            yscale = xscale;
    end
    axis([0 xscale 0 yscale]);
    grid on; box on
end