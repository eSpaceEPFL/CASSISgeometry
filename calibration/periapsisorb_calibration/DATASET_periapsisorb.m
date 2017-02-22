function set = DATASET_periapsisorb(dataset_path, subset_name)

    set.name = subset_name;

    % Function returns all folder pertained to CaSSIS starfield dataset
	 warning ('off','all'); % to prevent warnings on folder creation
    
	if( strcmp('periapsis_orbit09', subset_name) )
   
        subsetpath = [dataset_path '/CASSIS/aerobraking/161122_periapsis_orbit09'];
    
    elseif( strcmp('periapsis_orbit10', subset_name) )
   
        subsetpath = [dataset_path '/CASSIS/aerobraking/161126_periapsis_orbit10'];
                
    else
        
        error('No set with such name');
        
    end
    
    % root
    set.root = subsetpath;
    
        
    % ----------- input -----------------
   
    % framelets and xmls
    set.level1 = [subsetpath '/level1'];    
    
    % kernel
    set.spice = [dataset_path '/naif/ExoMars2016/kernels/mk/em16_ops_st.tm'];
        
    % ----------- output --------------
    
    mkdir(subsetpath,  'OUTPUT');
        
    % combined frames
    set.sequences = [subsetpath '/OUTPUT/sequences'];
    mkdir([subsetpath '/OUTPUT/'], 'sequences');
    
    % combined frames
    set.raw_exposures = [subsetpath '/OUTPUT/raw_exposures'];
    mkdir([subsetpath '/OUTPUT/'], 'raw_exposures');
    
    % denoising
    set.denoise_exposure = [subsetpath '/OUTPUT/denoise_exposures'];
    mkdir([subsetpath '/OUTPUT/'],  'denoise_exposures');
        
    % ----------- summaries -------------

    % final parameters
    set.intrinsic_final = [subsetpath '/OUTPUT/intrinsic_final.csv'];
    set.lensDistortion_final = [subsetpath '/OUTPUT/lensDistortion_final.csv'];
    set.sysRotErr_final = [subsetpath '../../sysRotErr_final.csv'];
    
    set.extrinsic_spice = [subsetpath '/OUTPUT/extrinsic0_spice.csv'];
    set.rotCommand = [subsetpath '/OUTPUT/rotCommand.csv'];
    
    % folder content summary
    set.folderContent = [subsetpath '/OUTPUT/folderContent.csv']; 
    
    % sequences summary
    set.sequencesSummary = [subsetpath '/OUTPUT/sequencesSummary.csv']; 
        
    % exposure summary
    set.exposuresSummary = [subsetpath '/OUTPUT/exposuresSummary.csv']; 
        
    warning ('on','all');
end
