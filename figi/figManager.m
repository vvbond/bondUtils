function figManager
% Figures View manager

figHandles = sort(get(0,'Children'));
N = length(figHandles);

figNames = get(figHandles, 'Name');
dum = find(strcmpi('Figure View Manager', figNames));
if ~isempty(dum)
    figure(dum);
    return;
end
figNumNames = strcat(num2str((1:N)'),'. ', figNames);
    
% Defaults
ncols = 2; % Fixed number of columns

% Create listbox with figure names
scrsz = get(0,'ScreenSize');
w = 500;
h = max(N*17, 150);
l = scrsz(3)/2-w-10;
b = scrsz(4)-h-50;

figPos = [l b w h];
% Create figure
hMain = figure('Toolbar', 'none', 'Menubar', 'none',...
               'Name', 'Figure View Manager', ...
               'NumberTitle', 'off', 'Position', figPos);
% ________________________________________ Create listbox with figure names
l_lb = 5;
b_lb = 5;
w_lb = w-80;
h_lb = h-10;
hLB = uicontrol('Style', 'Listbox', 'String', figNumNames,...
                'Position', [l_lb b_lb w_lb h_lb],...
                'Min', 1, 'Max', N);
% _________________________________________________ Create additional items
l = l_lb+w_lb+10;
b = b_lb+(h_lb-50) - (0:3)*25;
w = 50;
h = 20;
% Static text
hST = uicontrol('Style', 'text', 'String', '# rows', ...
                'Position', [l b(1)+30 w 15]);
% Popup menu with number of rows
hPM = uicontrol('Style', 'Popupmenu', ...
                'String', {'auto', '1', '2', '3', '4', '5'}, ...
                'Position', [l b(1) 50 30]);
% Create show button
hSB = uicontrol('Style', 'Pushbutton', 'String', 'Tile',...
                'Position', [l b(2) w h],...
                'Callback', {@tb_callback});
% Create tile button
hTB = uicontrol('Style', 'Pushbutton', 'String', 'Show',...
                'Position', [l b(3) w h],...
                'Callback', {@sb_callback});

% Create close button
hSB = uicontrol('Style', 'Pushbutton', 'String', 'Close',...
                'Position', [l b(4) w h],...
                'Callback', {@cb_callback});

            
% _______________________________________________________Callback Functions
    function sb_callback(src, eventdata)
        fig_ix = get(hLB, 'Value');
        showfigs(figHandles(fig_ix));
    end
    
    function cb_callback(src, eventdata)
        fig_ix = get(hLB, 'Value');
        delfigs(figHandles(fig_ix));
        set(hLB, 'Value', 1);
        
        figHandles = sort(get(0,'Children'));
        figNames = get(figHandles, 'Name');
        dum = find(strcmpi('Figure View Manager', figNames));
        figHandles(dum) = []; % Delete the handle for View Manager
        N = length(figHandles);
        figNames = get(figHandles, 'Name');
        figNumNames = strcat(num2str((1:N)'),'. ', figNames);
        set(hLB, 'String', figNumNames);
    end
    
    function tb_callback(src, eventdata)
        fig_ix = get(hLB, 'Value');
        Nfigs = length(fig_ix);
        nrows = get(hPM, 'Value')-1;
        if nrows == 0
            nrows = ceil(Nfigs/ncols);
            if nrows==1
                nrows = 2;
            end
        end
        tilefigs(nrows, figHandles(fig_ix));
    end
end