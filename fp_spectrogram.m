function fp_spectrogram(fp, windowFcn, nfft, noverlap, fs)
% fPoker user function: compute and display spectrogram of the monitored data.
    
    if fp.xMonitorRunning
        t = fp.xplot(:,1);
        x = fp.xplot(:,2);
        figNum = fp.hXfig + 1;
        titleStr = sprintf('x = %1.2f;  ix = %1d', fp.p(1), fp.pix(1));
    elseif fp.yMonitorRunning
        t = fp.yplot(:,1);
        x = fp.yplot(:,2);
        figNum = fp.hYfig + 1;
        titleStr = sprintf('y = %1.2f;  ix = %1d', fp.p(2), fp.pix(2));
    else
        return;
    end
%     windowFcn = str2func(windowFcnName);
    if nargin < 5
        fs = 1/(t(2)-t(1));
    else
        t = (0:length(x)-1)./fs;
    end
    [s, f, t1] = spectrogram(x, windowFcn(nfft), noverlap, nfft, fs);
    s = abs(s).^2;
    s(2:end-1,:) = 2*s(2:end-1,:);
    hfig = figure(figNum); clf;
    hfig.Position(3) = fp.hfig.Position(3);
    hfig.Position(4) = 1000;
    subplot(2,1,1); plot(t,x); xlabel('Time');
    title(titleStr);
    grid on, box on
    subplot(2,1,2); imagesc(t1,f,10*log10(s)); axis xy; 
    xlabel('Time'); ylabel('Frequency');
    try 
        linkaxes(gsuba, 'x'); 
    end
end