function [t_list, exp_list, subexp_list, fname_list] = cassis_find_subexp(path)
% Finds all packages in folder and saves:
% Time
% Package  #
% Exposure #

xml_fpat = [path '/*.xml']; 
xml_files = dir(xml_fpat); 
nb_files = length(xml_files);

cnt = 0;

nb_packages = 0;
for nfile = 1:nb_files

    fname = xml_files(nfile).name;
    
    [isdmp, time, exp, subexp] = cassis_parse_filename(fname);
        
    if ~isdmp % we dont want dumps
        
        nb_packages = nb_packages + 1;
                
        t_list(nb_packages) = cassis_time2num(time);
        exp_list(nb_packages) = exp;
        subexp_list(nb_packages) = subexp;
        fname_list{nb_packages} = fname;
    
    end
    
end

end