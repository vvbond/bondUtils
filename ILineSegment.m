classdef ILineSegment < handle
% Interactive line segment.
%
% Example:
%  figure, axis(axis*5);  iseg = ILineSegment() TODO
%  figure, axis(axis*10); iseg = ILineSegment(); TODO
%
% See also: IBezier, IPoint.

    properties(Dependent)
        len
        slope
        xrng
        yrng
        xdata
        ydata
    end

    properties(SetObservable)
        cpt             % 2-vector of control points IPoint.
        width = 1       % line width.
        color           % line color.
        style           % line style.
    end
    
    properties(Hidden)
        hline
        hax
        cache
    end    
    %% {Con,De}structor
    methods
        function iseg = ILineSegment(varargin)
        % Create a line segment in 2D.
        %
        % Usage:    iseg = ILineSegment
        %           iseg = ILineSegment(cpt)
        %
        % INPUT:
        %  none     - create Bezier curve interactively in the current figure.
        %  cpt      - up to 2 control points. Either a k-vector of IPoints or 
        %             a 2-by-k array of [x; y] coordintates of k control points.
        %             If k is less than 2, the remaining control point is
        %             specified interactively.
        %
        % Example:
        %  figure, axis(axis*5);  iseg = ILineSegment() TODO
        %  figure, axis(axis*10); iseg = ILineSegment(); TODO
        %
        % See also: IPoint, IBezier.
        
            if nargin
                val = varargin{1};
                if isa(val, 'IPoint') && numel(val) <= 2
                    cpt = val;
                elseif ismatrix(val) && size(val,2) <= 2
                    for ii=1:size(val,2)
                        cpt(ii) = IPoint(val(:,ii)); %#ok<*AGROW>
                    end
                end
            else
                cpt = IPoint;
            end
            
            if length(cpt) < 2
                for ii=length(cpt)+1:2
                    cpt(ii) = IPoint; %#ok<*AGROW>
                end
            end
            iseg.cpt = cpt;
            iseg.hax = gca;
            iseg.plot;
            
            % Listeners:
            addlistener(cpt, 'pChange', @(src,evt) cpt_PostSet_cb(iseg, src, evt));
            
            % Setup user-interaction:
            for ii=1:2
                iseg.cpt(ii).user_bmcb{1} = @(ipt) bmcb(iseg, ipt);
            end
        end
        
        function delete(iseg)
            delete(iseg.cpt);
            delete(iseg.hline);
        end
    end
    
    %% Static methods
%     methods(Static)
%         function iseg = loadobj(iseg)
%             addlistener(iseg, 'n', 'PostSet', @(src,evt) n_PostSet_cb(iseg, src, evt));
%         end
%     end
        
    %% Plotting & interaction
    methods
        function plot(iseg)
            figure(gcf);
            % Plot the line:
            hold on
            iseg.hline = plot(iseg.xdata, iseg.ydata, 'LineWidth', iseg.width);
            
            if ~isempty(iseg.color)
                set(iseg.hline, 'color', iseg.color);
            end
            if ~isempty(iseg.style)
                set(iseg.hline, 'LineStyle', iseg.style);
            end

            addlistener(iseg, 'color', 'PostSet', @(src,evt) color_PostSet_cb(iseg, src, evt) );
            addlistener(iseg, 'width', 'PostSet', @(src,evt) width_PostSet_cb(iseg, src, evt) );
            addlistener(iseg, 'style', 'PostSet', @(src,evt) style_PostSet_cb(iseg, src, evt) );

            % Plot the control points, if not yet plotted:
            for ii=1:2
                try 
                    if isempty(iseg.cpt(ii).hp.Parent) || isempty(iseg.cpt(ii).hp.Parent.Parent)
                        iseg.cpt(ii).plot; 
                    end
                catch
                    iseg.cpt(ii).plot;
                end
                uistack(iseg.cpt(ii).hp, 'top');
            end
            
            % Interaction with the line segment:
            set(iseg.hline, 'ButtonDownFcn', @(src,evt) lbdcb(iseg,src,evt));
        end
        
        function update_plot(iseg)
            set(iseg.hline, 'xdata', iseg.xdata, 'ydata', iseg.ydata);
        end
                
        function bmcb(iseg, ~)
            iseg.update_plot;
        end
        
        % Line button down callback.
        function lbdcb(iseg,~,~)
            iseg.cache.cpos = get(gca, 'CurrentPoint');
            % Store old interaction callbacks:
            iseg.cache.buttonMotionFcn  = get(iseg.hax.Parent, 'WindowButtonMotionFcn');
            iseg.cache.buttonUpFcn      = get(iseg.hax.Parent, 'WindowButtonUpFcn');
            
            
            % Set new interaction callbacks:
            set(gcf, 'WindowButtonMotionFcn', @(src,evt) wbmcb(iseg, src, evt),...
                     'WindowButtonUpFcn',     @(src,evt) wbucb(iseg, src, evt));
        end
        
        function wbmcb(iseg, ~,~)
            cpos = get(gca, 'CurrentPoint');
            dp = (cpos(1,1:2) - iseg.cache.cpos(1,1:2))';
            iseg.cpt(1).p = iseg.cpt(1).p + dp;
            iseg.cpt(2).p = iseg.cpt(2).p + dp;
            iseg.cache.cpos = cpos;
        end
        
        function wbucb(iseg, ~,~)
            % Restore the old interaction callbacks:
            set(iseg.hax.Parent, 'WindowButtonMotionFcn', iseg.cache.buttonMotionFcn,...
                                 'WindowButtonUpFcn',     iseg.cache.buttonUpFcn);
        end
        
    end
    
    %% Auxiliary methods
    methods(Hidden)        
        function cpt_PostSet_cb(iseg, ~, ~)
            iseg.update_plot;
        end
        
        function color_PostSet_cb(iseg, ~, ~)
            set(iseg.hline, 'color', iseg.color);
        end
        
        function width_PostSet_cb(iseg, ~, ~)
            set(iseg.hline, 'LineWidth', iseg.width);
        end

        function style_PostSet_cb(iseg, ~, ~)
            set(iseg.hline, 'LineStyle', iseg.style);
        end
    end
    %% Setters/Getters
    methods
        function val = get.xdata(iseg)
            val = [iseg.cpt(1).p(1) iseg.cpt(2).p(1)];
        end

        function val = get.ydata(iseg)
            val = [iseg.cpt(1).p(2) iseg.cpt(2).p(2)];
        end
        
        function val = get.xrng(iseg)
            val = abs(diff(iseg.xdata));
        end
        
        function val = get.yrng(iseg)
            val = abs(diff(iseg.ydata));
        end

        
        function val = get.len(iseg)
            val = sqrt(diff(iseg.xdata)^2 + diff(iseg.ydata)^2);
        end
        
        function val = get.slope(iseg)
            val = diff(iseg.ydata)/diff(iseg.xdata);
        end
    end
end