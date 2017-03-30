classdef IBezier3 < handle
    properties
        cpt     % control points.
        l       % line points.
    end
    
    properties(Hidden)
        t
        n = 2000
        hline
        hwhisker
        hfig
        hax
    end
    
    %% {Con, De}structor
    methods
        function ibz = IBezier3(varargin)
            if nargin
                val = varargin{1};
                if isa(val, 'IPoint') && numel(val) == 4                    
                    ibz.cpt = val;
                elseif ismatrix(val) && size(val,2) == 4
                    for ii=1:4
                        cpt(ii) = IPoint(val(:,ii)); %#ok<*AGROW>
                    end
                    ibz.cpt = cpt;
                end
            else
                for ii=1:4
                    cpt(ii) = IPoint; %#ok<*AGROW>
                end
                ibz.cpt = cpt;
            end
            ibz.t = linspace(0,1, ibz.n);
            ibz.hfig = gcf;
            ibz.hax = gca;
            ibz.compute_line;
            ibz.plot;
            
            % Setup user-interaction:
            for ii=1:4
                ibz.cpt(ii).user_bmcb{1} = @(ipt) bmcb(ibz, ipt);
            end
        end
        
        function delete(ibz)
            delete(ibz.cpt);
            delete(ibz.hline);
            delete(ibz.hwhisker);
        end
    end
    
    %% Bezier computation and plotting
    methods
        function p = point(ibz, t)
            p = (1-t).^3.*ibz.cpt(1) + 3*(1-t).^2.*t.*ibz.cpt(2) + 3*(1-t).*t.^2.*ibz.cpt(3) + t.^3.*ibz.cpt(4);
        end
        
        function dpdt = derivative(ibz,t)
            dpdt = 3*(1-t).^2.*(ibz.cpt(2)-ibz.cpt(1)) + 6*(1-t).*t.*(ibz.cpt(3)-ibz.cpt(2)) + 3*t.^2.*(ibz.cpt(4)-ibz.cpt(3));
        end
        
        function len = length(ibz, t1, t2)
            switch nargin
                case 1
                    tstart = 0;
                    tend   = 1;
                case 2
                    tstart = 0;
                    tend = t1;
                case 3
                    tstart = t1;
                    tend   = t2;
            end
            
            ds = @(t) sqrt(sum(ibz.derivative(t).^2));
            
            for ii=1:length(tstart)
                for jj=1:length(tend)
                    len(ii,jj) = integral(ds, tstart(ii), tend(jj));
                end
            end
        end
        
        function compute_line(ibz)
            t = ibz.t; %#ok<*PROP>
            ibz.l = ibz.point(t);
            
        end
        
        function plot(ibz)
            figure(ibz.hfig); hold on
            ibz.hline = plot(ibz.l(1,:), ibz.l(2,:));
            ibz.hwhisker(1) = plot([ibz.cpt(1).p(1) ibz.cpt(2).p(1)], [ibz.cpt(1).p(2) ibz.cpt(2).p(2)], 'k--');
            ibz.hwhisker(2) = plot([ibz.cpt(3).p(1) ibz.cpt(4).p(1)], [ibz.cpt(3).p(2) ibz.cpt(4).p(2)], 'k--');
            set(ibz.hline, 'PickableParts', 'none');
            set(ibz.hwhisker, 'PickableParts', 'none');
        end
        
        function update_plot(ibz)
            set(ibz.hline, 'xdata', ibz.l(1,:), 'ydata', ibz.l(2,:));
            set(ibz.hwhisker(1), 'xdata', [ibz.cpt(1).p(1) ibz.cpt(2).p(1)], 'ydata', [ibz.cpt(1).p(2) ibz.cpt(2).p(2)]);
            set(ibz.hwhisker(2), 'xdata', [ibz.cpt(3).p(1) ibz.cpt(4).p(1)], 'ydata', [ibz.cpt(3).p(2) ibz.cpt(4).p(2)]);
        end
        
        function bmcb(ibz, ~)
            ibz.compute_line;
            ibz.update_plot;
        end
    end
end