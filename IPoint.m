classdef IPoint < handle
% Interactive 2D point.
%
% Features:
%  drug-and-drop
%  change programmatically: position, marker, face color.
%
% Usage:
%  figure; axis(axis*10); ipt = IPoint;

    properties(SetObservable)
        p                   % 2-vector of [x;y] coordinates.
        marker = 'o'
        color
        faceColor
    end
    
    properties(Dependent)
        delta
    end
    
    properties(Hidden)
        p_old
        hp
        oldButtonMotionFcn
        oldButtonUpFcn
        user_bmcb = {}
        user_bdcb = {}
    end
    
    events
        pChange
    end
    
    methods
        %% {Con,De}structor
        function ipt = IPoint(varargin)
            
            if nargin
                switch nargin
                    case 1
                        ipt.p = varargin{1};
                    case 2
                        ipt.p = varargin{1};
                        ipt.marker = varargin{2};  
                end
            else
                ipt.p = ginput(1)';
            end
            ipt.p_old = ipt.p;
            ipt.plot();
        end
        
        function delete(ipt)
            delete(ipt.hp);
        end
    end
    
    %% Operator overloading
    methods
        function d = double(ipt)
            d = ipt.p;
        end
        
        function r = plus(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a + b;
        end
        
        function r = minus(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a - b;
        end
        
        function r = times(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a .* b;
        end
        
        function r = mtimes(obj1, obj2)
            a = double(obj1);
            b = double(obj2);
            r = a * b;
        end
    end
    
    %% Setters & Getters
    methods
        function set.p(ipt, val)
            if ~isvector(val) || numel(val)~=2, error('Value must be a 2-vector.'); end
            ipt.p = val(:);
        end
        
        function val = get.delta(ipt)
            val = ipt.p - ipt.p_old;
        end
    end
    
    %% Plotting
    methods
        function plot(ipt)
            figure(gcf); hold on
            ipt.hp = plot(ipt.p(1), ipt.p(2), ipt.marker);
            hold off
            
            % Interactive callbacks:
            set(ipt.hp, 'ButtonDownFcn', @(src,evt) bdcb(ipt, src, evt));
            addlistener(ipt, 'p', 'PreSet',  @(src,evt) p_PreSet_cb(ipt, src, evt));
            addlistener(ipt, 'p', 'PostSet', @(src,evt) p_PostSet_cb(ipt, src, evt) );
            addlistener(ipt, 'marker',    'PostSet', @(src,evt) marker_PostSet_cb(ipt, src, evt) );
            addlistener(ipt, 'color',     'PostSet', @(src,evt) color_PostSet_cb(ipt, src, evt) );
            addlistener(ipt, 'faceColor', 'PostSet', @(src,evt) faceColor_PostSet_cb(ipt, src, evt) );
        end                
    end
       
    %% Interactivity
    methods(Hidden)
        function updatePlot(ipt)
            set(ipt.hp, 'XData', ipt.p(1), 'YData', ipt.p(2));
        end

        function bdcb(ipt, ~,~)
            % Store old interaction callbacks:
            ipt.oldButtonMotionFcn  = get(gcf, 'WindowButtonMotionFcn');
            ipt.oldButtonUpFcn      = get(gcf, 'WindowButtonUpFcn');
            
            % Set new interaction callbacks:
            set(gcf, 'WindowButtonMotionFcn', @(src,evt) wbmcb(ipt, src, evt),...
                     'WindowButtonUpFcn',     @(src,evt) wbucb(ipt, src, evt));
            for ii=1:length(ipt.user_bdcb)
                ipt.user_bdcb{ii}(ipt);
            end
                      
        end
        
        function wbmcb(ipt, ~,~)
            cpos = get(gca, 'CurrentPoint');
            ipt.p = cpos(1,1:2)';
%             ipt.updatePlot();
            for ii=1:length(ipt.user_bmcb)
                ipt.user_bmcb{ii}(ipt);
            end
        end
        
        function wbucb(ipt, ~,~)
            % Restore the old interaction callbacks:
            set(gcf, 'WindowButtonMotionFcn', ipt.oldButtonMotionFcn,...
                     'WindowButtonUpFcn',     ipt.oldButtonUpFcn);
        end
        
         function p_PreSet_cb(ipt, ~, ~)
             ipt.p_old = ipt.p;
         end

        function p_PostSet_cb(ipt, ~, ~)
            ipt.updatePlot;
            notify(ipt, 'pChange');
        end
              
        function marker_PostSet_cb(ipt, src, evt)
            set(ipt.hp, 'marker', ipt.marker);
        end
        
        function color_PostSet_cb(ipt, src, evt)
            set(ipt.hp, 'color', ipt.color);
        end
 
        function faceColor_PostSet_cb(ipt, src, evt)
            set(ipt.hp, 'MarkerFaceColor', ipt.faceColor);
        end

    end
end