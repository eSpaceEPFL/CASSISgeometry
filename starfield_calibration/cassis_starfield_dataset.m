function set = cassis_starfield_dataset(dataset_path, subset_name)
    % Function returns all folder pertained to CaSSIS starfield dataset
          
    if( strcmp('commissioning_1', subset_name) )
        subsetpath = [dataset_path '/COM/160407_commissioning_1'];  
    elseif( strcmp('commissioning_2', subset_name) )
        subsetpath = [dataset_path '/COM/160407_commissioning_2'];
    elseif( strcmp('pointing_spacecraft', subset_name) )
        subsetpath = [dataset_path '/COM/160412_pointing_spacecraft'];
    elseif( strcmp('pointing_cassis', subset_name) )
        subsetpath = [dataset_path '/COM/160413_pointing_cassis'];
    elseif( strcmp('interference', subset_name) )
        subsetpath = [dataset_path '/COM/160418_interference'];
    else
        error('No set with such name');
    end
    
    % framelets and xmls
    set.level0 = [subsetpath '/level0'];    
    
    % combined frames
    set.raw = [subsetpath '/OUT_raw'];
    
    % darkframes
    set.denoise = [subsetpath '/OUT_denoise'];
      
    % recognized stars
    set.recognize = [subsetpath '/OUT_recognize'];
    
    
end
