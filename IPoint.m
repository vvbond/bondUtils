classdef IPoint < handle
    properties
        p
        marker = 'o'
        faceColor
    end
    
    properties(Hidden)
        hfig
        hp
        oldButtonMotionFcn
        oldButtonUpFcn
        user_bmcb = {}
        user_bdcb = {}
    end
    methods
        %% {Con, De}structor
        function ipt = IPoint(varargin)
            
            ipt.hfig = gcf;
            if nargin
                switch nargin
                    case 1
                        ipt.p = varargin{1};
                    case 2
                        ipt.p = varargin{1};
                        ipt.marker = varargin{2};  
                end
            else
                figure(ipt.hfig);
                ipt.p = ginput(1)';
            end
            figure(ipt.hfig); hold on
            ipt.hp = plot(ipt.p(1), ipt.p(2), ipt.marker);
            hold off
            
            % Interactive callbacks:
            set(ipt.hp, 'ButtonDownFcn', @(src,evt) bdcb(ipt, src, evt));
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
    
    %% Plotting
    methods
        function updatePlot(ipt)
            set(ipt.hp, 'XData', ipt.p(1), 'YData', ipt.p(2));
        end
    end
       
    %% Interactivity
    methods(Hidden)
        function bdcb(ipt, ~,~)
            % Store old interaction callbacks:
            ipt.oldButtonMotionFcn  = get(gcf, 'WindowButtonMotionFcn');
            ipt.oldButtonUpFcn      = get(gcf, 'WindowButtonUpFcn');
            
            % Set new interaction callbacks:
            set(ipt.hfig, 'WindowButtonMotionFcn', @(src,evt) wbmcb(ipt, src, evt),...
                          'WindowButtonUpFcn',     @(src,evt) wbucb(ipt, src, evt));
            for ii=1:length(ipt.user_bdcb)
                ipt.user_bdcb{ii}(ipt);
            end
                      
        end
        
        function wbmcb(ipt, ~,~)
            cpos = get(gca, 'CurrentPoint');
            ipt.p = cpos(1,1:2)';
            ipt.updatePlot();
            for ii=1:length(ipt.user_bmcb)
                ipt.user_bmcb{ii}(ipt);
            end
        end
        
        function wbucb(ipt, ~,~)
            % Restore the old interaction callbacks:
            set(gcf, 'WindowButtonMotionFcn', ipt.oldButtonMotionFcn,...
                     'WindowButtonUpFcn',     ipt.oldButtonUpFcn);
        end
    end
end