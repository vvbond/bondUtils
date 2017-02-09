%% format figures

% Style specifications:

% Background color (letter or [r g b] vector)
bg_color = 'w';
% bg_color = 'default';
% Font sizes
title_sz = 16; % figure title
label_sz = 14; % axes labels
font_sz  = 12; % axes fonts

% Format
figs = get(0,'Children');
figs = sort(figs);
for i=1:length(figs)
    nf = figs(i);
    % format figure
    set(nf, 'Color', bg_color);
    % format axeses in the figure
    axs = get(nf, 'Children');
    for jj = 1:length(axs)
        % Set axes fonts
        try set(axs(jj), 'FontSize', font_sz);
        catch
        end
        % Set fonts for axes labels and title
        try 
            set(get(axs(jj), 'xlabel'), 'FontSize', label_sz);
            set(get(axs(jj), 'ylabel'), 'FontSize', label_sz);
            set(get(axs(jj), 'title'), 'FontSize', title_sz);
        catch
        end
    end
end
clear figs i nf bg_color title_sz label_sz font_sz;