function set = cassis_starfield_dataset(dataset_path, subset_name)
    % Function returns all folder pertained to CaSSIS starfield dataset
          
    if( strcmp('commissioning_2', subset_name) )
        subsetpath = [dataset_path '/COM/160407_commissioning_2'];
        set.ignorelist = {};
    elseif( strcmp('pointing_spacecraft', subset_name) )
        subsetpath = [dataset_path '/COM/160412_pointing_spacecraft'];
        set.ignorelist = {'2016-04-12T20.13.03.765', '2016-04-13T22.04.13.816', '2016-04-12T20.46.03.749'} 
    elseif( strcmp('pointing_cassis', subset_name) )
        subsetpath = [dataset_path '/COM/160413_pointing_cassis'];
        set.ignorelist = {};
    else
        error('No set with such name');
    end
    
    % framelets and xmls
    set.level0 = [subsetpath '/level0'];    
    
    % table of all images
    set.imglist = [subsetpath '/imglist.txt']; 
    
    % table of active images
    set.activelist = [subsetpath '/activelist.txt']; 
    
    % combined frames
    set.raw = [subsetpath '/OUT_raw'];
    
    % darkframes
    set.denoise = [subsetpath '/OUT_denoise'];
      
    % recognized stars
    set.recognize = [subsetpath '/OUT_recognize'];
    
    % spice meta kernel
    set.spice = [subsetpath '/casssoft/SPICE/meta.tm'];
    
end
