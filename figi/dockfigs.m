%% This util docks all opened figures
figs = get(0,'Children');
figs = sort(figs);
for i=1:length(figs)
    set(figs(i),'WindowStyle','docked');
end
clear figs