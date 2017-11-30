function pickolor()
    fh = figure;
    set(fh, 'Menu', 'none', 'toolbar', 'none', 'NumberTitle', 'off', 'Name', 'Pickolor!', 'resize', 'off');
    fh.Position(3) = 750;
    fh.Position(4) = 400;
    cc = javax.swing.JColorChooser;
    [jColorChooser, hColorChooser] = javacomponent(cc,[1,1,758,395], fh);
end