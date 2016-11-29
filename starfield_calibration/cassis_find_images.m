function frames = cassis_find_images(path)

% Given path to directory functions search for sequences of exposures and 

xml_fpat = [path '/*.xml']; 
xml_files = dir(xml_fpat); 
nb_files = length(xml_files);

cnt = 0;

frames = {};
for nfile = 1:nb_files

    fname = xml_files(nfile).name;
    substr = strsplit(fname, '-');
    
    if ~strcmp(substr{6},'DMP') % we dont want dumps
        
        time = [substr{3} '-' substr{4} '-' substr{5}];
        exp = str2num(substr{7}(end-2:end));
        
        if( ~ismember(time, frames) ) % check if this is part of previously observed frame 
            cnt = cnt + 1;
            frames{cnt} = time;
        end
    end
    
end

end