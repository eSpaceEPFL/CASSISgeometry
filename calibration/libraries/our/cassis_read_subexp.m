function [I, win, exp] = cassis_read_subexp(fname, type)

% Function reads package by time

%t_str = cassis_num2time(t)
%xml_fpat = [path '/*' t_str '*' num2str(pac) '*.xml']; 
%xml_file = dir(xml_fpat); 

%xml_fname = [path '/' xml_file(1).name];
xml = xml2struct(fname);

win_idx         = 1 + str2num(xml.Product_Observational.CaSSIS_Header.FSW_HEADER.Attributes.WindowCounter);
win_row_start   = 1 + str2num(xml.Product_Observational.CaSSIS_Header.PEHK_HEADER.Attributes.(sprintf('Window%i_Start_Row',win_idx)));
win_row_end     = 1 + str2num(xml.Product_Observational.CaSSIS_Header.PEHK_HEADER.Attributes.(sprintf('Window%i_End_Row',win_idx)));
win_col_start   = 1 + str2num(xml.Product_Observational.CaSSIS_Header.PEHK_HEADER.Attributes.(sprintf('Window%i_Start_Col',win_idx)));
win_col_end     = 1 + str2num(xml.Product_Observational.CaSSIS_Header.PEHK_HEADER.Attributes.(sprintf('Window%i_End_Col',win_idx)));

framelet_height =  win_row_end - win_row_start + 1;
framelet_width = win_col_end - win_col_start + 1;
win = [win_col_start, win_row_start, framelet_width, framelet_height ];
exp = str2num(xml.Product_Observational.CaSSIS_Header.PEHK_HEADER.Attributes.Exposure_Time);

% Read data stripe
dat_fname = [fname(1:end-4) '.dat'];
f = fopen(dat_fname, 'r');
I = zeros(framelet_height, framelet_width); 
tmp = fread(f, [framelet_width framelet_height], type)';
if size(tmp,1) == size(I,1) && size(tmp,2) == size(I,2)
    I = tmp;
end
fclose(f);

end