classdef RoI1 < handle
    % Interactive tool for specifying a 1D region of interest (ROI).
    %   Detailed explanation goes here
    
    properties
        rng                 % 2-vector specifying the [from to] range of the ROI.
        lineStyle           % string, specifies the color and style of the vertical lines.
        lineColor           % color of the two side lines.
        lineWidth           % scalar, defines the width of the vertical lines.
        on                  % binary state indicator: 0 - ROI is off, 1 - ROI is on.
        displayFcn          % handle of the display function, returning an info string: str = f(rng).
                            % Default: @(rng) ['ROI: [' num2str(rng(:)', '%5.2f ') ']' ].
        displayPosition    % 4-vector of [left top height width] parameters of the display box. Default: [.7 .85 .1 .1]
        userFcn            % user-defined function, called on mouse motion event.
    end
    
    properties(Hidden = true)
        hfig    % figure handle.
        hax     % axes handle.
        htbar   % toolbar handle.
        hbtn    % the tool's toolbar button.
        hline   % array of 3 line handles: [left, right, top].
        lineIx  % index (1 or 2) of the currently selected line.
        hinfobx % handle of the info box.
        
        % Previous state of the figure:
        old_bdcb
        old_bucb
        old_bmcb
        old_fpointer
        old_NextPlot
    end
    
    methods
        %% Constructor
        function r1 = roi1(rng)
            
            % Create roi button:
            r1.hfig  = gcf;
            r1.hax   = gca;
            r1.htbar = findall(gcf,'Type','uitoolbar');
            roi1Icon = load('roi1Icon.mat');
            r1.hbtn = uitoggletool(r1.htbar,  'CData', roi1Icon.cdata, ...
                                              'OnCallback',  @(src,evt) roiOn(r1,src,evt),...
                                              'OffCallback', @(src,evt) roiOff(r1,src,evt),...
                                              'tooltipstring', 'ROI',...
                                              'Separator', 'on');
            % Defaults:
            r1.lineStyle = '-';
            r1.lineColor = [.5 .5 .5];
            r1.lineWidth = 2;
            r1.displayPosition = [.65 .85 .1 .1];
            
            % Range initialization:
            r1.rng = [];
            if nargin == 1
                r1.rng = rng;
            end
            
            r1.lineIx = 0;
            r1.on = 0;
            r1.displayFcn = @(rng) ['ROI: [' num2str(rng(:)', '%5.2f ') ']  (' num2str(diff(rng), '%5.2f)') ];
        end
        
        %% Destructor
        function delete(r1)
            if ishandle(r1.hfig)
                delete(r1.hbtn);
                if ishandle(r1.hline)
                    delete(r1.hline);
                end
            end
        end
        
        %% ROI on callback
        function roiOn(r1,~,~)
            
            if isempty(r1.rng)      % if range is not initialized yet.
                xlims = get(gca,'xlim')';
                r1.rng = xlims(1) + diff(xlims)*[1; 2]./3;
            end
                        
            % Plot ROI lines:
            r1.old_NextPlot = get(gca,'NextPlot');
            hold on;
            
            % Turn off other interactive tools:
            zoom off, pan off, datacursormode off

            % Plot ROI lines:
            ylims = get(r1.hax, 'ylim');
            r1.hline = [ plot([1 1]*r1.rng(1), ylims, r1.lineStyle, 'lineWidth', r1.lineWidth, 'color', r1.lineColor); 
                         plot([1 1]*r1.rng(2), ylims, r1.lineStyle, 'lineWidth', r1.lineWidth, 'color', r1.lineColor);
%                          plot(r1.rng, [1 1]*ylims(2), 'g-', 'lineWidth', 10);
                       ];
            ylim(ylims);            
            
            % Restore the hold status:
            set(gca,'NextPlot',r1.old_NextPlot);
            
            % Set the interaction callbacks:
            set(r1.hline([1 2]), 'buttonDownFcn', @(src,evt) roi1_bdcb(r1,src,evt));
            set(gca, 'buttonDownFcn', @(src,evt) roi1_axis_bdcb(r1,src,evt));
            
            
            % Display the info box:
            r1.hinfobx = annotation('textbox', r1.displayPosition,...
                            'String', r1.infoString(),...
                            'FontSize', 12, ...
                            'FontWeight', 'bold',...
                            'BackgroundColor', [.9 .9 .9],...
                            'Tag', 'roi1.info' ...
                          );
                      
            % Update the roi state:
            r1.on = 1;
        end
        
        %% ROI off callback
        function roiOff(r1,~,~)
            
            % Update the roi state:
            r1.on = 0;

            % Delete ROI lines:
            if ishandle(r1.hline),   delete(r1.hline);   end
            if ishandle(r1.hinfobx), delete(r1.hinfobx); end
        end
        
        %% Interactions: button down callback
        function roi1_bdcb(r1,src,~)
            r1.lineIx = find(src == r1.hline);
            
            % Store the current window motion function:
            r1.old_bmcb = get(r1.hfig, 'WindowButtonMotionFcn');
            r1.old_bucb = get(r1.hfig, 'WindowButtonUpFcn');
            
            set(r1.hfig, 'windowButtonMotionFcn', @(src,evt) roi1_wbmcb(r1,src,evt, 0),...
                         'windowButtonUpFcn',     @(src,evt) roi1_wbucb(r1,src,evt) );
        end
        
        function roi1_axis_bdcb(r1,src,evt)
            cpos = get(gca, 'currentPoint');
            if inarange(cpos(1,1), r1.rng)
                r1.lineIx = 1;
                dx = r1.rng(1) - cpos(1,1);
                set(r1.hfig, 'windowButtonMotionFcn', @(src,evt) roi1_wbmcb(r1,src,evt, dx),...
                              'windowButtonUpFcn',    @(src,evt) roi1_wbucb(r1,src,evt) );
            end
        end
        
        %% Interactions: window button motion callback
        function roi1_wbmcb(r1,~,~, dx)
            if r1.lineIx
                roi_width = diff(r1.rng);
                cpos = get(gca, 'currentPoint');
                r1.rng(r1.lineIx) = cpos(1,1) + dx;
                % Update plot:
                set(r1.hline(r1.lineIx), 'xdata', [1 1]*r1.rng(r1.lineIx));
                if dx ~= 0     % update the second (end) line if dragging the roi.
                    r1.rng(2) = r1.rng(1) + roi_width;
                    set(r1.hline(2), 'xdata', [1 1]*r1.rng(2));
                end
                set(r1.hinfobx, 'String', r1.infoString() );
                
                % Call user-defined function:
                if ~isempty(r1.userFcn)
                    r1.userFcn(r1);
                    figure(r1.hfig);
                end
            end
        end
        
        %% Interactions: window button up callback
        function roi1_wbucb(r1,~,~)
            r1.lineIx = 0;
            set(r1.hfig, 'windowButtonMotionFcn', r1.old_bmcb);
            set(r1.hfig, 'windowButtonUpFcn', r1.old_bucb);
        end        
        
        %% ROI update:
        function update(r1)
            
            % If ROI is not enabled, quit:
            if ~r1.on, return; end
            
            ylims = get(r1.hax, 'ylim');
            % Lines:
            set(r1.hline(1), 'xdata', [1 1]*r1.rng(1), 'ydata', ylims);
            set(r1.hline(2), 'xdata', [1 1]*r1.rng(2), 'ydata', ylims);
%             set(r1.hline(3), 'xdata', r1.rng, 'ydata', [1 1]*ylims(2));
            
            % Info box:
            set(r1.hinfobx, 'String', r1.infoString);
        end
        
        %% Construct infobox string
        function s = infoString(r1)
%             s = ['ROI: [' num2str(r1.rng', '%5.2f ') ']' ];
            s = r1.displayFcn(r1.rng);
        end
    end 
end

