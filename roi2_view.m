function roi2_view(rr, hax)
% Update the axis limits according to the roi.
%
% INPUT:
%  rr       - ROI2 object.
%  hax      - axes handle.

    set(hax, 'xlim', rr.xrng, 'ylim', rr.yrng);
end