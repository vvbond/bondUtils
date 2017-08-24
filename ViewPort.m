classdef ViewPort < handle
% Viewport.
%
% Usage:
%
% Examples:
% vp = ViewPort(10000, 200); 
% for ii = 1:500, vp.push(rand(1000, randi(100))); pause(.01); end

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
        unit_rows = 'm'
        unit_cols = 's'
        label_rows = 'Location'
        label_cols = 'Time'
        decimateFactor_rows
        decimateFactor_cols
        playBtn
    end
    properties(Hidden)
        colCount = 0;
        hfig
        htbar
        himg
        hax
        hax_top
        hplot
        roi 
        roi_himg
        fp
        roiViewBtn
    end
    properties(Dependent)
        nCols_decimated
        nRows_decimated
    end
    methods
        %% {Con,De}structor
        function vp = ViewPort(width_s, updateStep_s, spacing_cols, spacing_rows)
            
            % Parse input:
            vp.width_s = width_s;
            vp.updateStep_s = updateStep_s;
            % Optional arguments:
            if nargin == 2
                vp.spacing_cols = 1;
                vp.spacing_rows = 1;
            elseif nargin == 3
                vp.spacing_cols = spacing_cols;
                vp.spacing_rows = 1;
            else
                vp.spacing_cols = spacing_cols;
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
            
            % Define decimation:
            scrSz = get(0,'ScreenSize');
            scrWidth = scrSz(3); scrHeight = scrSz(4);
            vp.decimateFactor_cols = max(1, floor(vp.nCols/scrWidth));
            
            % Init figure:
            if ~(~isempty(vp.hfig) && ishandle(vp.hfig(1)))  % Double negation trick imposes check break on empty condition.
                vp.init_figure;
            end

            if isempty(vp.nRows), return; end
            
            vp.decimateFactor_rows = max(1, floor(vp.nRows/scrHeight));
            
            % Create buffers:
            vp.bfr_data = CircBuffer(vp.nRows, vp.nCols);
            vp.bfr_disp = CircBuffer(vp.nRows_decimated, vp.nCols_decimated);
            
            % Zero the linear column count:
            vp.colCount = 0;
            
            vp.init_image;
        end
        
        function init_figure(vp)
        % Init the main figure.
            
            vp.hfig = figure(randi(1e6)); clf
            set(vp.hfig, 'Name', 'Viewport', 'NumberTitle', 'off');
            
            % Create toggle buttons:
            vp.htbar = findall(vp.hfig(1),'Type','uitoolbar'); % Find the toolbar.
            
            % Play button:
            if isempty(findobj(vp.htbar(1), 'Tag', 'playBtn'))
                playIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/playIcon.mat'));
                vp.playBtn = uitoggletool(vp.htbar(1), 'CData', playIcon.cdata, ...
                                                       'TooltipString', 'Play', ...
                                                        'Tag', 'playBtn',... 
                                                        'Separator', 'on',...
                                                        'Enable', 'off');
            end
            
            % Figure resize function:
            set(vp.hfig, 'SizeChangedFcn', @(src,evt) vp.figSizeChanged_cb);
        end
        
        function init_image(vp)
        % Init image.
            if vp.nRows == 1
                vp.hplot = plot( (0:vp.nCols_decimated-1)*vp.spacing_cols*vp.decimateFactor_cols, vp.bfr_disp.data);
                xlabel(sprintf('%s [%s]', vp.label_cols, vp.unit_cols));
                % Enable RoI tool:
                if exist('RoI1', 'file'), vp.roi = RoI1; end
            else
                delete(findobj(vp.hfig, 'type', 'image'));
                delete(findobj(vp.hfig, 'type', 'axes'));
                vp.hax = gca;
                vp.himg = imagesc(vp.hax, 'XData', (0:vp.nCols_decimated-1)*vp.spacing_cols*vp.decimateFactor_cols,... 
                                          'YData', (0:vp.nRows_decimated-1)*vp.spacing_rows*vp.decimateFactor_rows,...
                                          'CData', vp.bfr_disp.data);
                axis tight;
                xlabel(sprintf('%s [%s]', vp.label_cols, vp.unit_cols));
                ylabel(sprintf('%s [%s]', vp.label_rows, vp.unit_rows));
                
                % Interactive colorbar if possible:
                if exist('iColorBar', 'file') && false
                    iColorBar;
                else
                    colorbar;
                end 
                
                % Top axis:
                if ishandle(vp.hax_top), delete(vp.hax_top); end
                vp.hax_top = axes('Position', vp.hax.Position, 'XAxisLocation', 'top', 'color', 'none');
                vp.hax_top.YAxis.Visible = 'off';
                vp.hax_top.XAxis.Limits = sort(-vp.hax.XAxis.Limits);
                linkaxes([vp.hax, vp.hax_top], 'y');
                
                % Enable RoI tool:
                if exist('RoI2', 'file') 
                    vp.roi = RoI2;
                    vp.roi.userFcn = @(src,evt) vp.roiViewHandler(src,evt);
                end
            end
                        
            % ROI view button:
            if isempty(findobj(vp.htbar(1), 'Tag', 'roiViewBtn')) && ~isempty(vp.roi)
                roiViewIcon = load(fullfile(fileparts(mfilename('fullpath')),'/icons/roiViewIcon.mat'));
                vp.roiViewBtn = uitoggletool(vp.htbar(1),   'CData', roiViewIcon.cdata, ...
                                                            'OnCallback', @(src,evt) vp.roiView,...
                                                            'OffCallback', @(src,evt) vp.roiViewOff,...
                                                            'TooltipString', 'View ROI', ...
                                                            'Tag', 'roiViewBtn',... 
                                                            'Separator', 'off',...
                                                            'Enable', 'off');
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
                % Update top axis:
                vp.hax_top.XAxis.Limits = vp.bfr_data.count*vp.spacing_cols - [vp.width_s 0];
            end
        end
        
        %% Plot
        function roiView_update(vp)
            
            if length(vp.hfig) == 1, return; end
            if ~ishandle(vp.hfig(2)), return; end
                
            cols = 1:vp.nCols;
            rows = 1:vp.nRows;
            roi_rows = inarange(rows, vp.roi.yrng_ix*vp.decimateFactor_rows);
            roi_cols = inarange(cols, vp.roi.xrng_ix*vp.decimateFactor_cols);
            cols_wrapped = vp.bfr_data.ix(roi_cols);
            
            SubD = vp.bfr_data.D(roi_rows, cols_wrapped);
            xData = (cols(roi_cols)-1)*vp.spacing_cols;
            yData = (rows(roi_rows)-1)*vp.spacing_rows;
            set(vp.roi_himg, 'cdata', SubD,...
                                 'xdata', xData,...
                                 'ydata', yData);
        end
        
        function roiView(vp)
        % Create full resolution subview of data within the roi.
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
            xlabel(sprintf('%s [%s]', vp.label_cols, vp.unit_cols));
            ylabel(sprintf('%s [%s]', vp.label_rows, vp.unit_rows));            
            axis tight
            colormap parula
            iColorBar;
            
            if exist('fPoker', 'file')==2
                vp.fp = fPoker;
                vp.fp.monitor('y');
            end
        end
        
        function roiViewOff(~)
            % Place holder.
        end
        
        %% Setters & Getters
        function val = get.nCols_decimated(vp)
            val = ceil(vp.nCols/vp.decimateFactor_cols);
        end
        
        function val = get.nRows_decimated(vp)
            val = ceil(vp.nRows/vp.decimateFactor_rows);
        end
        %% Wrappers
        function write(vp, A)
            vp.push(A);
        end
    end
    
    %% Misc
    methods(Hidden)
        function roiViewHandler(vp, ~, evt)
            if ~isempty(regexpi(evt, 'roi2_created'))
                vp.roiViewBtn.Enable = 'on';
            elseif ~isempty(regexpi(evt, 'roi2_deleted'))
                vp.roiViewBtn.State = 'off';
                vp.roiViewBtn.Enable = 'off';
            elseif ~isempty(regexpi(evt, 'roi2_move|roi2_resize'))
                vp.roiView_update;
            end
        end
        
        function figSizeChanged_cb(vp)
            if ~isempty(vp.hax_top) && ishandle(vp.hax_top)
                vp.hax_top.Position = vp.hax.Position;
            end
        end
    end
end