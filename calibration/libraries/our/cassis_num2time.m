function time_str = cassis_num2time(time_num)
    % Converts number of days from 0 year to time stamp of cassis image (string)  
    time_str = datestr(time_num, 'yyyy-mm-ddTHH.MM.SS.FFF');    
end
