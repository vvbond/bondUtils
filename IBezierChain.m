classdef IBezierChain < handle
% Construct a chain of cubic Bezier curves in 2D.
%
% Usage:
%
% Example:
%
%  figure, axis(axis*10); ibz = IBezier3([1 1 4 4; 2 4 2 4]); bzch = IBezierChain(ibz); bzch.add_segment
%
% See also: IBezier3, IPoint.

    properties
        segment
    end
    
    properties(Dependent)
        l
        n
    end
    
    %% {Con,De}structor
    methods        
        function bzch = IBezierChain(segment)
            if isa(segment, 'IBezier3')
                bzch.segment = segment;
            else
                error('Wrong argument type. Must be an IBezier3 segment.');
            end
        end
        
        function delete(bzch)
            delete(bzch.segment);
        end
    end
    
    %% Segments
    methods
        function add_segment(bzch)
        % Add an IBezier segment.
            bzch.segment = [bzch.segment IBezier3(bzch.segment(end).cpt(4))];
        end
        
        function plot(bzch)
            for ii=1:bzch.n
                bzch.segment(ii).plot;
            end
        end
        
        function toggle_controls(bzch)
            for ii=1:bzch.n
                bzch.segment(ii).toggle_controls;
            end
        end
        
        function junction_smooth(bzch, k)
            if nargin==1, k=1; end
            
            % Adjust the control points symmetrically around the junction point:
            bzch.smooth_junction_symmetry_constraint(k, k+1);
            
            % Add the symmetry constraint:
            bzch.segment(k).cpt(3).user_bmcb{2} = @(ipt) smooth_junction_symmetry_constraint(bzch, k, k+1, ipt);
            bzch.segment(k+1).cpt(2).user_bmcb{2} = @(ipt) smooth_junction_symmetry_constraint(bzch, k+1, k, ipt);
            
            % Add central point constraint:
            bzch.segment(k).cpt(4).user_bmcb{2} = @(ipt) smooth_junction_centre_constraint(bzch, k, k+1, ipt);
        end
        
        function smooth_junction_symmetry_constraint(bzch, seg1, seg2, ~)
            if seg2 > seg1
                bzch.segment(seg2).cpt(2).p = 2*bzch.segment(seg1).cpt(4).p - bzch.segment(seg1).cpt(3).p;
            else
                bzch.segment(seg2).cpt(3).p = 2*bzch.segment(seg1).cpt(1).p - bzch.segment(seg1).cpt(2).p;
            end
            bzch.segment(seg2).compute_line;
            bzch.segment(seg2).update_plot;
        end
        
        function smooth_junction_centre_constraint(bzch, seg1, seg2, ipt)
            bzch.segment(seg1).cpt(3).p = bzch.segment(seg1).cpt(3).p + ipt.delta;
            bzch.segment(seg2).cpt(2).p = bzch.segment(seg2).cpt(2).p + ipt.delta;
            bzch.segment(seg2).compute_line;
            bzch.segment(seg2).update_plot;
        end
        
        function corner_junction_centre_constraint(bzch, seg2, ~)
            bzch.segment(seg2).compute_line;
            bzch.segment(seg2).update_plot;
        end
        
        function junction_corner(bzch, k)
            if nargin==1, k=1; end
            bzch.segment(k).cpt(4).user_bmcb{2} = @(ipt) corner_junction_centre_constraint(bzch, k+1, ipt);
            bzch.segment(k).cpt(3).user_bmcb(2) = [];
            bzch.segment(k+1).cpt(2).user_bmcb(2) = [];
        end
    end
    
    %% Line
    methods
        function l = get.l(bzch)
            l = [];
            for ii=1:length(bzch.segment)
                l = [l bzch.segment(ii).l]; %#ok<AGROW>
            end
        end
               
        function len = curve_length(bzch, p1, p2)
        % Length of the curve between points p0 and p1. 
        % The points are parametrized as 2-vectors: [segment t].
   
            switch nargin
                case 1
                    pstart = [1, 0]; 
                    pend   = [bzch.n, 1];
                case 2
                    pstart = [1, 0];
                    pend = p1;
                case 3
                    pstart = p1;
                    pend   = p2;
            end
            
            % Sanity check:
            if numel(pstart) ~=2 || numel(pend) ~= 2
                error('The input must be 2-vector, [segment# t]');
            end
            if pstart(1)<0 || pstart(1)>bzch.n || pend(1)<0 || pend(1)>bzch.n
                error('The segment number is out of range.');
            end
            if pstart(2)<0 || pstart(2)>1 || pend(2)<0 || pend(2)>1
                error('The parameter t must be in [0 1].')
            end
            
            % Get the length:
            if pstart(1)>pend(1), dum = pstart; pstart = pend; pend = dum; end
            
            if pstart(1) == pend(1)
                len = bzch.segment(pstart(1)).curve_length(pstart(2), pend(2));
            else
                len1 = bzch.segment(pstart(1)).curve_length(pstart(2), 1);
                len2 = bzch.segment(pend(1)).curve_length(0, pend(2));
                len3 = 0;
                for seg = pstart(1)+1:pend(1)-1
                    len3 = len3 + bzch.segment(seg).curve_length;
                end
                len = len1 + len2 + len3;
            end
        end
    end
    
    %% Auxliary methods
    methods
        function n = get.n(bzch)
            n = length(bzch.segment);
        end
    end
end