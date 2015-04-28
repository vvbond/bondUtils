%% this util undocks all the docked figures
figs = get(0,'Children');
for i=1:length(figs)
    set(figs(i),'WindowStyle','normal')
end
clear figs