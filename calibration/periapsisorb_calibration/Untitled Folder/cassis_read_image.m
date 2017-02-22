function [I, mask, exposure] = cassis_read_image(path, time, format)

%clear all;
%path = '/HDD1/Data/CASSIS/2014_05_26_TGO_STARFIELD/160407_commissioning_2/level0';
%utimes = cassis_find_images(path);
%time = utimes{1};

nb_win = 4;
im_width  = 2048;
im_height = 2048;

xml_fpat = [path '/*' time '*.xml']; 
xml_files = dir(xml_fpat); 
nb_files = length(xml_files);

I = zeros([im_height, im_width], 'uint16');
mask = false(im_height, im_width);
for nfile = 1:nb_files
    % Get information about position fo current data stripe within image
    % win_idx - idx of current window
    % win_row_start, win_row_end, ... - position of current data stripe within image
    xml_fname = [path '/' xml_files(nfile).name];
    xml = xml2struct(xml_fname);
    win_idx         = 1 + str2num(xml.Product_Observational.CaSSIS_Header.FSW_HEADER.Attributes.WindowCounter);
    win_row_start   = 1 + str2num(xml.Product_Observational.CaSSIS_Header.PEHK_HEADER.Attributes.(sprintf('Window%i_Start_Row',win_idx)));
    win_row_end     = 1 + str2num(xml.Product_Observational.CaSSIS_Header.PEHK_HEADER.Attributes.(sprintf('Window%i_End_Row',win_idx)));
    win_col_start   = 1 + str2num(xml.Product_Observational.CaSSIS_Header.PEHK_HEADER.Attributes.(sprintf('Window%i_Start_Col',win_idx)));
    win_col_end     = 1 + str2num(xml.Product_Observational.CaSSIS_Header.PEHK_HEADER.Attributes.(sprintf('Window%i_End_Col',win_idx)));
    
    exposure = str2num(xml.Product_Observational.CaSSIS_Header.PEHK_HEADER.Attributes.Exposure_Time);
    
    % Read data stripe
    dat_fname = [xml_fname(1:end-4) '.dat'];
    f = fopen(dat_fname, 'r');
    framelet_height =  win_row_end - win_row_start + 1;
    framelet_width = win_col_end - win_col_start + 1;
    data = fread(f, [framelet_width framelet_height], format)';
    fclose(f);
    
    % Fit datastripe in image
    I(win_row_start:win_row_end, win_col_start:win_col_end) = data; 
    mask(win_row_start:win_row_end, win_col_start:win_col_end) = true; 
    
end
mask = flip(mask);
I = flip(I);

end