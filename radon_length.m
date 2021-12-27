function l = radon_length(theta, xp, sz)
% Lenght of the radon transform projection line for given theta and radial coordinate xp.

    alpha = theta*pi/180;
    delta = xp;
    
    ctr = floor((sz([2 1])+1)/2)' - 1;     % 
            
    vn = [cos(alpha); sin(alpha)];  % normal.
    shift = ctr'*vn + delta;        % shift.
    
    % compute line's length:
    Pxx = [ (shift - sin(alpha)*[0 sz(1)-1])/cos(alpha);
            0 sz(1)-1 ];
    Pyy = [ 0 sz(2)-1 ;
           (shift - cos(alpha)*[0 sz(2)-1])/sin(alpha) ];
    P = [ Pxx(:, within(Pxx(1,:), [0 sz(2)-1])) Pyy(:, within(Pyy(2,:), [0 sz(1)-1])) ];
    if ~isempty(P)
        l = norm(diff(P,[],2));
        l = max(l, 1);
    else
        l = NaN;
    end

end