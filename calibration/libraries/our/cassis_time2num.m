function time_num = cassis_time2num(time_str)
    % Converts time stamp of cassis image (string) to number of days from 
    % 0 year
    time_num = datenum(time_str, 'yyyy-mm-ddTHH.MM.SS.FFF');    
end
