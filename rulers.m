function rulers(onOffSwitch)

if nargin == 0
    onOffSwitch = 1;
end

if ~onOffSwitch
    delete(findall(gcf, 'tag', 'rulersLine'));
    delete(findall(gcf, 'tag', 'rulersInfo'));
    return;
end
             

zoom off, pan off, datacursormode off
%% Rulers in a 2D plot
xlims = get(gca,'xlim')';
ylims = get(gca,'ylim')';

dx = diff(xlims);
dy = diff(ylims);
A = [1 2
     1 2]./3;
lpos = [ xlims(1)+A*dx, ylims(1)+A*dy ]; % lines position [x1 x2 y1 y2].
 
hold on;
hlines = [ plot(lpos(:, 1:2), ylims, 'g--', 'LineWidth', 2, 'Tag', 'rulersLine');
           plot(xlims, lpos(:, 3:4), 'g--', 'LineWidth', 2, 'Tag', 'rulersLine') ];

xlim(xlims);
ylim(ylims);

sp = '      ';
sp1 = '  ';
infoTxt = { ['    x_1', sp, 'x_2', sp 'dx', sp],...
            [num2str(lpos(1,1)), sp1, num2str(lpos(1,2)), sp1, num2str(abs(diff(lpos(1,1:2)))) ],...
            ['    y_1', sp, 'y_2', sp, 'dy', sp],...
            [num2str(lpos(1,3)), sp1, num2str(lpos(1,4)), sp1, num2str(abs(diff(lpos(1,3:4)))) ]};
hinfobx = annotation('textbox', [.13 .1 .1 .1], ...
                     'string', infoTxt,... 
                     'Color', 'k', 'BackgroundColor', 'y', 'EdgeColor', 'k', ...
                     'Tag', 'rulersInfo');

%% Set interactions:
clix = 0; % current line index.
set(hlines, 'ButtonDownFcn', @lbdcb);
set(gcf, 'WindowButtonMotionFcn', @wbmcb, ...
         'WindowButtonUpFcn', @wbucb)

    function lbdcb(src, ~)
    % Line button down callback.
        clix = find(src == hlines); % line index.
    end

    function wbmcb(~, ~)
    % Window button motion callback.
        if clix
            cpos = get(gca, 'CurrentPoint');
            cxpos = cpos(1,1); % cursor x position.
            cypos = cpos(1,2); % cursor x position.
            switch clix>2
                case 0
                    lpos(:,clix) = [1;1]*cxpos;
                    set(hlines(clix), 'XData', lpos(:,clix));
                    % Update info text:
                    infoTxt{2} = [num2str(lpos(1,1)), sp1, num2str(lpos(1,2)), sp1, num2str(abs(diff(lpos(1,1:2))))];
                case 1
                    lpos(:,clix) = [1;1]*cypos;
                    set(hlines(clix), 'YData', lpos(:,clix));
                    % Update info text:
                    infoTxt{4} = [num2str(lpos(1,3)), sp1, num2str(lpos(1,4)), sp1, num2str(abs(diff(lpos(1,3:4))))];                   
            end
            % Update info box:
            set(hinfobx, 'String', infoTxt);
        end
    end

    function wbucb(~,~)
    % Window button up callback.
        clix = 0;
    end
end