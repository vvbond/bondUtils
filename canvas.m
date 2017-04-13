function canvas(scale_factor)
    if nargin==0, scale_factor = 10; end
    axis([0 1 0 1]*scale_factor);
    grid on; box on
end