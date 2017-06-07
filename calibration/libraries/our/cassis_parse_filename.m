function [isdmp, time, exp, subexp] = cassis_parse_filename(fname)
    
    substr = strsplit(fname, '-');
    isdmp = strcmp(substr{6},'DMP');
        
    time = [substr{3} '-' substr{4} '-' substr{5}];
    exp = str2num( substr{7}(end-2:end) );
    subexp = str2num(substr{7}(1:2));
    
end