function plotcols(D, nplots, batchNum)
% Plot columns of D in a number of subplots.
    
    if nargin == 1
        nplots = 6;
        batchNum = 1;
    elseif nargin == 2
        batchNum = 1;
    end

    startCol = (batchNum-1)*nplots;
    
    % Find nrows and ncols, such that nrows*ncols >= n, and nrows \approx ncols.
    ncols = 2;
    nrows = ceil(nplots/ncols);
    
    while (nrows - ncols) > 2
        ncols = ncols + 1;
        nrows = ceil(nplots/ncols);
    end
    
    [~, n] = size(D);
    for ii=1:nplots
        subplot(nrows, ncols, ii);
        colIx = ii+startCol;
        if colIx <= n
            plot(D(:, ii+startCol));
        end
    end
end