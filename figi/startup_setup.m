function startup_setup(dockORnot)

set(0, 'DefaultAxesFontSize', 14, 'DefaultAxesLineWidth', .7, ...
       'DefaultLineLineWidth', 1, 'DefaultPatchLineWidth', .7 );

switch dockORnot
    case 1
        set(0,'DefaultFigureWindowStyle','docked');
    case 0
        scrsz = get(0,'ScreenSize');
        width = scrsz(3)/4-5;
        height = scrsz(4)/2.4;
        left = scrsz(3)/2+5;
        bottom = scrsz(4) - height;
        set(0, 'DefaultFigureWindowStyle', 'normal', ...
               'DefaultFigurePosition'   , [left bottom width height]);
        clear scrsz
end