classdef ViewPort < handle
    properties
        bfr_disp                    % Circular bufferes for display and
        bfr_data                    % data.
        nRows
        nCols
        width_s
        updateStep_s
        updateStep_cols
        spacing_rows
        spacing_cols
        units_rows = 'm'
        units_cols = 's'
        label_rows = 'Location'
        label_cols = 'Time'
        decimateFactor_rows
        decimateFactor_cols
        
        colCount = 0;
       
        hfig
        himg
        hplot
        roi
        roi_himg
        fp
        playBtn
    end
    methods
        %% {Con,De}structor
        function vp = ViewPort(width_s, updateStep_s, spacing_cols, spacing_rows)
            
            % Parse input:
            vp.width_s = width_s;
            vp.updateStep_s = updateStep_s;
            vp.spacing_cols = spacing_cols;
            if nargin == 3
                vp.spacing_rows = 1;
            else
                vp.spacing_rows = spacing_rows;
            end
            
            vp.init();
        end
        
        function delete(vp)
            delete(vp.bfr_data);
            delete(vp.bfr_disp);
            delete(vp.roi);
            if ishandle(vp.hfig), delete(vp.hfig); end
        end
        
        %% Initialization
        function init(vp)
            
            vp.nCols = floor(vp.width_s/vp.spacing_cols);
            vp.updateStep_cols = floor(vp.updateStep_s/vp.spacing_cols);
            
            % Decimation:
            scrSz = get(0,'ScreenSize');
            scrWidth = scrSz(3); scrHeight = scrSz(4);
            vp.decimateFactor_cols = max(1, floor(vp.nCols/scrWidth));
            nCols_decimated = ceil(vp.nCols/vp.decimateFactor_cols);
            
            if isempty(vp.nRows), return; end
            
            vp.decimateFactor_rows = max(1, floor(vp.nRows/scrHeight));
            nRows_decimated = ceil(vp.nRows/vp.decimateFactor_rows);
            
            % Create buffers:
            vp.bfr_data = CircBuffer(vp.nRows, vp.nCols);
            vp.bfr_disp = CircBuffer(nRows_decimated, nCols_decimated);
            
            % Setup figure:
            vp.hfig(1) = figure(randi(1e6)); clf
            if vp.nRows == 1
                vp.hplot = plot( (0:nCols_decimated-1)*vp.spacing_cols*vp.decimateFactor_cols, vp.bfr_disp.data);
                xlabel(sprintf('%s [%s]', vp.label_cols, vp.units_cols));
                if exist('RoI1', 'file'), vp.roi = RoI1; end
            else
                vp.himg = imagesc( (0:nCols_decimated-1)*vp.spacing_cols*vp.decimateFactor_cols,... 
                                   (0:nRows_decimated-1)*vp.spacing_rows*vp.decimateFactor_rows,...
                                   vp.bfr_disp.data);
                xlabel(sprintf('%s [%s]', vp.label_cols, vp.units_cols));
                ylabel(sprintf('%s [%s]', vp.label_rows, vp.units_rows));
                if exist('RoI2', 'file'), vp.roi = RoI2; end
            end
            
            % Create toggle buttons:
            ht = findall(vp.hfig(1),'Type','uitoolbar'); % Find the toolbar.
            
            % ROI view button:
            if isempty(findobj(ht, 'Tag', 'roiViewBtn')) && ~isempty(vp.roi)
                roiViewIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/roiViewIcon.mat'));
                uitoggletool(ht(1), 'CData', roiViewIcon.cdata, ...
                                    'OnCallback', @(src,evt) vp.roiView,...
                                    'OffCallback', @(src,evt) vp.roiViewOff,...
                                    'TooltipString', 'View ROI', ...
                                    'Tag', 'roiViewBtn',... 
                                    'Separator', 'off');
            end
            
            % Play button:
            if isempty(findobj(ht, 'Tag', 'playBtn'))
                playIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/playIcon.mat'));
                vp.playBtn = uitoggletool(ht(1), 'CData', playIcon.cdata, ...
                                                 'TooltipString', 'Play', ...
                                                 'Tag', 'playBtn',... 
                                                 'Separator', 'on');
            end
        end
             
        %% Push
        function push(vp, D)
            if isempty(vp.nRows) 
                vp.nRows = size(D,1);
                vp.init();
            end
            
            vp.bfr_data.push(D);
            vp.bfr_disp.push(D(1:vp.decimateFactor_rows:end, 1:vp.decimateFactor_cols:end));
            
            vp.colCount = vp.colCount + size(D,2);
            if vp.colCount > vp.updateStep_cols
                if vp.nRows == 1
                    set(vp.hplot, 'ydata', vp.bfr_disp.data);
                else
                    set(vp.himg, 'cdata', vp.bfr_disp.data);
                    caxis auto
                    drawnow
                end
                vp.colCount = mod(vp.colCount, vp.updateStep_cols);
            end
        end
        
        %% Plot
        function roiView_update(vp, r)
            
            if ~ishandle(vp.hfig(2)), return; end
                
            cols = 1:vp.nCols;
            rows = 1:vp.nRows;
            roi_rows = inarange(rows, r.yrng_ix*vp.decimateFactor_rows);
            roi_cols = inarange(cols, r.xrng_ix*vp.decimateFactor_cols);
            cols_wrapped = vp.bfr_data.ix(roi_cols);
            
            SubD = vp.bfr_data.D(roi_rows, cols_wrapped);
            xData = (cols(roi_cols)-1)*vp.spacing_cols;
            yData = (rows(roi_rows)-1)*vp.spacing_rows;
            set(vp.roi_himg, 'cdata', SubD,...
                                 'xdata', xData,...
                                 'ydata', yData);
        end
        
        function roiView(vp)
            
            cols = 1:vp.nCols;
            rows = 1:vp.nRows;
            roi_rows = inarange(rows, vp.roi.yrng_ix*vp.decimateFactor_rows);
            roi_cols = inarange(cols, vp.roi.xrng_ix*vp.decimateFactor_cols);
            cols_wrapped = vp.bfr_data.ix(roi_cols);
            
            SubD = vp.bfr_data.D(roi_rows, cols_wrapped);
            
            xData = (cols(roi_cols)-1)*vp.spacing_cols;
            yData = (rows(roi_rows)-1)*vp.spacing_rows;
            
            vp.hfig(2) = figure(randi(1e6)); clf;
            fpos = get(vp.hfig(1), 'Position');
            S = diag([1 1 .75 .75]);
            fpos = fpos*S;
            set(vp.hfig(2), 'Position', fpos);
            vp.roi_himg = imagesc(xData, yData, SubD);            
            axis tight
            colormap parula
            iColorBar;
            vp.roi.userFcn = @(r) vp.roiView_update(r);
            xlabel(sprintf('%s [%s]', vp.label_cols, vp.units_cols));
            ylabel(sprintf('%s [%s]', vp.label_rows, vp.units_rows));
            
            if exist('fPoker', 'file')==2
                vp.fp = fPoker;
                vp.fp.monitor('y');
            end
        end
        
        function roiViewOff(vp)
            vp.roi.userFcn = [];
        end
        
        %% Wrappers
        function write(vp, A)
            vp.push(A);
        end
    end
end