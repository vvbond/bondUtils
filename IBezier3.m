classdef IBezier3 < handle
% Interactive cubic Bezier curve in 2D.
%
% Example:
%  figure, axis(axis*5);  ibz = IBezier3([1 1 4 4; 2 4 2 4])
%  figure, axis(axis*10); ibz = IBezier3([1;2]);
%
% See also: IBezierChain, IPoint.

    properties
        l               % 2-by-n array of [x; y] coordinates of n points representing the Bezier line.
    end
    
    properties(SetObservable)
        cpt             % control points.
        n = 1000        % discretization parameter, i.e., number of points.
        width = 1       % line width.
        color           % line color.
        style           % line style.
    end
    
    properties(Hidden)
        t
        hline
        hwhisker
        hax
    end
    
    %% {Con,De}structor
    methods
        function ibz = IBezier3(varargin)
        % Create a cubic Bezier curve in 2D.
        %
        % Usage:    ibz = IBezier3
        %           ibz = IBezeir3(cpt)
        %
        % INPUT:
        %  none     - create Bezier curve interactively in the current figure.
        %  cpt      - up to 4 control points. Either a k-vector of IPoints or 
        %             a 2-by-k array of [x; y] coordintates of k control points.
        %             If k is less than 4, the remaining control points are
        %             specified interactively.
        %
        % Example:
        %  figure, axis(axis*5);  ibz = IBezier3([1 1 4 4; 2 4 2 4])
        %  figure, axis(axis*10); ibz = IBezier3([1;2]);
        %
        % See also: IBezierChain, IPoint.
        
            if nargin
                val = varargin{1};
                if isa(val, 'IPoint') && numel(val) <= 4
                    cpt = val;
                elseif ismatrix(val) && size(val,2) <= 4
                    for ii=1:size(val,2)
                        cpt(ii) = IPoint(val(:,ii)); %#ok<*AGROW>
                    end
                end
            else
                cpt = IPoint;
            end
            
            if length(cpt) < 4
                for ii=length(cpt)+1:4
                    cpt(ii) = IPoint; %#ok<*AGROW>
                end
            end
            ibz.cpt = cpt;
            ibz.t = linspace(0,1, ibz.n);
            ibz.compute_line;
            ibz.hax = gca;
            ibz.plot;
            
            % Listeners:
            addlistener(ibz, 'n', 'PostSet', @(src,evt) n_PostSet_cb(ibz, src, evt));
            addlistener(cpt, 'pChange', @(src,evt) cpt_PostSet_cb(ibz, src, evt));
            
            % Setup user-interaction:
            for ii=1:4
                % A control point can refer to two Bezier segments.
                if ~isempty(ibz.cpt(ii).user_bmcb) && isa(ibz.cpt(ii).user_bmcb{1}, 'function_handle')
                    ibz.cpt(ii).user_bmcb{2} = @(ipt) bmcb(ibz, ipt);
                else
                    ibz.cpt(ii).user_bmcb{1} = @(ipt) bmcb(ibz, ipt);
                end
            end
        end
        
        function delete(ibz)
            delete(ibz.cpt);
            delete(ibz.hline);
            if all(ishandle(ibz.hwhisker)), delete(ibz.hwhisker); end
        end
    end
    
    %% Static methods
    methods(Static)
        function ibz = loadobj(ibz)
            addlistener(ibz, 'n', 'PostSet', @(src,evt) n_PostSet_cb(ibz, src, evt));
        end
    end
    
    %% Computations
    methods
        function p = point(ibz, t)
            p = (1-t).^3.*ibz.cpt(1) + 3*(1-t).^2.*t.*ibz.cpt(2) + 3*(1-t).*t.^2.*ibz.cpt(3) + t.^3.*ibz.cpt(4);
        end
        
        function compute_line(ibz)
            t = ibz.t; %#ok<*PROP>
            ibz.l = ibz.point(t);
        end
        
        function dpdt = derivative(ibz,t)
            dpdt = 3*(1-t).^2.*(ibz.cpt(2)-ibz.cpt(1)) + 6*(1-t).*t.*(ibz.cpt(3)-ibz.cpt(2)) + 3*t.^2.*(ibz.cpt(4)-ibz.cpt(3));
        end
        
        function c = curvature(ibz, t)
            c = 6*(1-t).*(ibz.cpt(3)-2*ibz.cpt(2)+ibz.cpt(1)) + 6*t.*(ibz.cpt(4)-2*ibz.cpt(3)+ibz.cpt(2));
        end
        
        function len = curve_length(ibz, varargin)
        % Length of the curve segment between points parametrized by t1 and t2.
            switch nargin
                case 1
                    tstart = 0;
                    tend   = 1;
                case 2
                    tstart = 0;
                    tend   = varargin{1};
                case 3
                    tstart = varargin{1};
                    tend   = varargin{2};
            end
            
            ds = @(t) sqrt(sum(ibz.derivative(t).^2));
            
            for ii=1:length(tstart)
                for jj=1:length(tend)
                    len(ii,jj) = integral(ds, tstart(ii), tend(jj));
                end
            end
        end
        
        function [t0, p0] = point_given_length(ibz, s0)
        % Find a point on the curve given the curve length from the origin to the point. 
            
            f = @(t) ibz.curve_length(t) - s0;
            t0 = fzero(f, .5);
            p0 = ibz.point(t0);
        end
               
        function [t, s, nn, d] = nearest_neighbour(ibz, pp)
        % Find a point on the Bezier curve nearest to the given point pp.
            
            % Parse input:
            if isvector(pp)
                pp = pp(:);
            end
            
            % Init:
            nPoints = size(pp, 2);
            d = zeros(1,nPoints);
            t = zeros(1,nPoints);
            nn = zeros(2,nPoints);
            
            % Find the nearest neighbor and distance to it:
            for ii=1:nPoints
                p = pp(:,ii);
                
            % Direct search:
%                 delta = p*ones(1, ibz.n) - ibz.l;
%                 dist = sqrt(sum(delta.^2));
%                 [dmin, ixmin] = min(dist);
%                 d(ii) = dmin;
%                 t(ii) = ibz.t(ixmin);

            % Minimization:
                distFun = @(t) norm(ibz.point(t) - p);
                [t(ii), d(ii)] = fminbnd(distFun, 0, 1);

                s(ii) = ibz.curve_length(t(ii));
                nn(:,ii) = ibz.point(t(ii));
            end
        end        
    end
    
    %% Plotting & interaction
    methods
        function plot(ibz)
            figure(gcf);
            % Plot the control points, if yet not plotted:
            for ii=1:4
                try 
                    if isempty(ibz.cpt(ii).hp.Parent) || isempty(ibz.cpt(ii).hp.Parent.Parent)
                        ibz.cpt(ii).plot; 
                    end
                catch
                    ibz.cpt(ii).plot;
                end
            end
            % Plot the line:
            hold on
            ibz.hline = plot(ibz.l(1,:), ibz.l(2,:), 'LineWidth', ibz.width);
            if ~isempty(ibz.color)
                set(ibz.hline, 'color', ibz.color);
            end
            if ~isempty(ibz.style)
                set(ibz.hline, 'LineStyle', ibz.style);
            end

            addlistener(ibz, 'color', 'PostSet', @(src,evt) color_PostSet_cb(ibz, src, evt) );
            addlistener(ibz, 'width', 'PostSet', @(src,evt) width_PostSet_cb(ibz, src, evt) );
            addlistener(ibz, 'style', 'PostSet', @(src,evt) style_PostSet_cb(ibz, src, evt) );
            % Add whiskers:
            ibz.hwhisker(1) = plot([ibz.cpt(1).p(1) ibz.cpt(2).p(1)], [ibz.cpt(1).p(2) ibz.cpt(2).p(2)], 'k--');
            ibz.hwhisker(2) = plot([ibz.cpt(3).p(1) ibz.cpt(4).p(1)], [ibz.cpt(3).p(2) ibz.cpt(4).p(2)], 'k--');
            % Make line non-responsive to mouse clicks:
            set(ibz.hline, 'PickableParts', 'none');
            set(ibz.hwhisker, 'PickableParts', 'none');
        end
        
        function update_plot(ibz)
            set(ibz.hline, 'xdata', ibz.l(1,:), 'ydata', ibz.l(2,:));
            set(ibz.hwhisker(1), 'xdata', [ibz.cpt(1).p(1) ibz.cpt(2).p(1)], 'ydata', [ibz.cpt(1).p(2) ibz.cpt(2).p(2)]);
            set(ibz.hwhisker(2), 'xdata', [ibz.cpt(3).p(1) ibz.cpt(4).p(1)], 'ydata', [ibz.cpt(3).p(2) ibz.cpt(4).p(2)]);
        end

        function controls_off(ibz)
            for ii=1:4
                set(ibz.cpt(ii).hp, 'visible', 'off');
            end
            set(ibz.hwhisker, 'visible', 'off');
        end

        function controls_on(ibz)
            for ii=1:4
                set(ibz.cpt(ii).hp, 'visible', 'on');
            end
            set(ibz.hwhisker, 'visible', 'on');
        end
        
        function controls_toggle(ibz)
            onoff = get(ibz.cpt(2).hp, 'visible');
            if strcmpi(onoff, 'off'), onoff = 'on'; else, onoff = 'off'; end
            for ii=1:4
                set(ibz.cpt(ii).hp, 'visible', onoff);
            end
            set(ibz.hwhisker, 'visible', onoff);
        end
        
        function bmcb(ibz, ~)
            ibz.compute_line;
            ibz.update_plot;
        end
    end
    
    %% Auxiliary methods
    methods(Hidden)
        function n_PostSet_cb(ibz, ~, ~)
            ibz.t = linspace(0,1, ibz.n);
            ibz.compute_line;
        end
        
        function cpt_PostSet_cb(ibz, ~, ~)
            ibz.compute_line;
            ibz.update_plot;
        end

        
        function color_PostSet_cb(ibz, ~, ~)
            set(ibz.hline, 'color', ibz.color);
        end
        
        function width_PostSet_cb(ibz, ~, ~)
            set(ibz.hline, 'LineWidth', ibz.width);
        end

        function style_PostSet_cb(ibz, ~, ~)
            set(ibz.hline, 'LineStyle', ibz.style);
        end

    end
end