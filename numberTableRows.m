function tb = numberTableRows(tb)
    tb.Properties.RowNames = mat2cell(num2str((1:height(tb))'), ones(height(tb),1));
end