classdef ViewPort < handle
    properties
        bfr_disp                    % Circular bufferes for display and
        bfr_data                    % data.
        nRows
        nCols
        width
        updateStep
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
        subview
        subview_himg
    end
    methods
        %% {Con,De}structor
        function vp = ViewPort(width, updateStep, spacing_cols, spacing_rows)
            
            % Parse input:
            vp.width = width;
            vp.updateStep = updateStep;
            vp.spacing_rows = spacing_rows;
            vp.spacing_cols = spacing_cols;
            
            vp.nCols = floor(vp.width/vp.spacing_cols);
            vp.updateStep_cols = floor(vp.updateStep/vp.spacing_cols);
            
        end
        
        %% Initialization
        function init(vp)
            
            % Decimation:
            scrSz = get(0,'ScreenSize');
            scrWidth = scrSz(3); scrHeight = scrSz(4);
            vp.decimateFactor_cols = max(1, floor(vp.nCols/scrWidth));
            vp.decimateFactor_rows = max(1, floor(vp.nRows/scrHeight));
            nCols_decimated = ceil(vp.nCols/vp.decimateFactor_cols);
            nRows_decimated = ceil(vp.nRows/vp.decimateFactor_rows);
            
            % Create buffers:
            vp.bfr_data = CircBuffer(vp.nRows, vp.nCols);
            vp.bfr_disp = CircBuffer(nRows_decimated, nCols_decimated);
            
            % Setup figure:
            vp.hfig(1) = figure(randi(1e6)); clf
            vp.himg = imagesc( (0:nCols_decimated-1)*vp.spacing_cols*vp.decimateFactor_cols,... 
                               (0:nRows_decimated-1)*vp.spacing_rows*vp.decimateFactor_rows,...
                               vp.bfr_disp.data);
            xlabel(sprintf('%s [%s]', vp.label_cols, vp.units_cols));
            ylabel(sprintf('%s [%s]', vp.label_rows, vp.units_rows));
            vp.subview = RoI2;
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
                set(vp.himg, 'cdata', vp.bfr_disp.data);
                caxis([-1 1]*3)
                drawnow
                
                vp.colCount = mod(vp.colCount, vp.updateStep_cols);
            end
        end
        
        %% Plot
        function subview_update(vp, r)
            
            roiData_rows = inarange(1:vp.nRows, r.yrng_ix*vp.decimateFactor_rows);
            roiData_cols = inarange(1:vp.nCols, r.xrng_ix*vp.decimateFactor_cols);
            cols_wraped = vp.bfr_data.ix(roiData_cols);
            
            SubD = vp.bfr_data.D(roiData_rows, cols_wraped);
            set(vp.subview_himg, 'cdata', SubD,...
                                 'xdata', vp.subview.xrng(1):vp.subview.xrng(2),...
                                 'ydata', vp.subview.yrng(1):vp.subview.yrng(2));
        end
        
        function subview_on(vp)
                       
            roiData_rows = inarange(1:vp.nRows, vp.subview.yrng_ix*vp.decimateFactor_rows);
            roiData_cols = inarange(1:vp.nCols, vp.subview.xrng_ix*vp.decimateFactor_cols);
            cols_wraped = vp.bfr_data.ix(roiData_cols);
            
            SubD = vp.bfr_data.D(roiData_rows, cols_wraped);
            vp.hfig(2) = figure(randi(1e6)); clf;
            vp.subview_himg = imagesc(vp.subview.xrng(1):vp.subview.xrng(2), vp.subview.yrng(1):vp.subview.yrng(2), SubD);            
            axis tight
            colormap gray
            iColorBar;
            vp.subview.userFcn = @(r) vp.subview_update(r);
            xlabel(sprintf('%s [%s]', vp.label_cols, vp.units_cols));
            ylabel(sprintf('%s [%s]', vp.label_rows, vp.units_rows));
        end
    end
end