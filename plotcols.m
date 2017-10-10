function plotcols(D, nplots, batchNum)
% Plot columns of D in a number of subplots.

    htbar = findall(gcf, 'Tag', 'FigureToolBar');    
    
    lbtn = findall(gcf, 'Tag', 'leftArrowBtn');
    rbtn = findall(gcf, 'Tag', 'rightArrowBtn');

    if isempty(lbtn)
        leftIcon = load(fullfile(fileparts(mfilename('fullpath')),'icons', 'leftIcon.mat'));
        lbtn = uipushtool(htbar, 'CData', leftIcon.cdata,  'tag',  'leftArrowBtn');
    end
        
    if isempty(rbtn)
        rightIcon = load(fullfile(fileparts(mfilename('fullpath')),'icons', 'rightIcon.mat'));
        rbtn = uipushtool(htbar, 'CData', rightIcon.cdata, 'tag', 'rightArrowBtn');
    end
    
    if nargin == 1
        nplots = 6;
        batchNum = 1;
    elseif nargin == 2
        batchNum = 1;
    end
    
    % Find nrows and ncols, such that nrows*ncols >= n, and nrows \approx ncols.
    ncols = 2;
    nrows = ceil(nplots/ncols);
    
    while (nrows - ncols) > 2
        ncols = ncols + 1;
        nrows = ceil(nplots/ncols);
    end
    
    [~, n] = size(D);
    
    subplots(batchNum);
    
    
    
    function subplots(batchNum)
        startCol = (batchNum-1)*nplots;
        for ii=1:nplots
            subplot(nrows, ncols, ii);
            colIx = ii+startCol;
            if colIx > 0 && colIx <= n
                plot(D(:, colIx));
                title(colIx);
            end
        end
        lbtn.ClickedCallback = @(src, evt) subplots(batchNum-1);
        rbtn.ClickedCallback = @(src, evt) subplots(batchNum+1);
    end
end