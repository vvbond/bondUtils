function ruler_xlineSpectrum(xline, figNum)
%% xline spectrum
    nPoints = length(xline);
    xdt = abs(xline(2,1)-xline(1,1));   % delta t along the line.
    if xdt == 0
        xdt = abs(xline(2,2)-xline(1,2));   % delta t along the line.
    end
    xfs = 1/xdt;                   % resulting sampling frequency.
    [pxx, f] = periodogram(xline(:,3), blackman(nPoints), [], xfs);
%     [pxx, f] = pcov(xline(:,3), 80, [], xfs);
    % Plot:
    figure(figNum);
    subplot(2,1,1);
    plot(f(f>1), pxx(f>1));
    grid on
    xlabel('Frequency [Hz]'); ylabel('PSD estimate');
    title('Power spectrum density');

    subplot(2,1,2);
    plot(f(f>1), 10*log10(pxx(f>1)));
    grid on
    xlabel('Frequency [Hz]'); ylabel('PSD estimate');
    title('Power spectrum density');
end