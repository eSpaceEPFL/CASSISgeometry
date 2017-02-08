function set = DATASET_starfields(dataset_path, subset_name)

    % Function returns all folder pertained to CaSSIS starfield dataset
	
	if( strcmp('commissioning_1', subset_name) )
        
        subsetpath = [dataset_path '/CASSIS/cruise/160407_commissioning_1'];
   
    elseif( strcmp('commissioning_2', subset_name) )
        
        subsetpath = [dataset_path '/CASSIS/cruise/160407_commissioning_2'];
    
    elseif( strcmp('pointing_spacecraft', subset_name) )

        subsetpath = [dataset_path '/CASSIS/cruise/160412_pointing_spacecraft'];
     
    elseif( strcmp('pointing_cassis', subset_name) )
      
        subsetpath = [dataset_path '/CASSIS/cruise/160413_pointing_cassis'];
   
    elseif( strcmp('mcc_abs_cal', subset_name) )
     
        subsetpath = [dataset_path '/CASSIS/cruise/160613_mcc_abs_cal'];
   
    elseif( strcmp('mcc_motor', subset_name) )
   
        subsetpath = [dataset_path '/CASSIS/cruise/160614_mcc_motor'];
   
    elseif( strcmp('stellar_cal_orbit10', subset_name) )
   
        subsetpath = [dataset_path '/CASSIS/aerobraking/161124_stellar_cal_orbit10'];
   
     elseif( strcmp('stellar_cal_orbit09', subset_name) )
   
        subsetpath = [dataset_path '/CASSIS/aerobraking/161120_stellar_cal_orbit09'];
       
    else
        error('No set with such name');
    end
    
    % root
    set.root = subsetpath;
    
        
    % ----------- input -----------------
   
    % framelets and xmls
    set.level0 = [subsetpath '/level0'];    
    
    % kernel
    set.spice = [dataset_path '/naif/ExoMars2016/kernels/mk/em16_ops_st.tm'];
        
    % ----------- output --------------
    
    % combined frames
    set.sequences = [subsetpath '/OUTPUT/sequences'];
    
    % combined frames
    set.raw_exposures = [subsetpath '/OUTPUT/raw_exposures'];
    
    % denoising
    set.denoise_exposure = [subsetpath '/OUTPUT/denoise_exposures'];
    
    % recognized stars
    set.recognize = [subsetpath '/OUTPUT/recognize']; 
    
    
    % ----------- summaries -------------

    % factory parameters
    set.intrinsic0 = [subsetpath '/OUTPUT/intrinsic0.csv'];
    set.lensDistortion0 = [subsetpath '/OUTPUT/lensDistortion0.csv'];
    set.extrinsic0 = [subsetpath '/OUTPUT/extrinsic0.csv'];
    
    % BA parameters
    set.extrinsic_ba = [subsetpath '/OUTPUT/extrinsic_ba.csv'];
    set.intrinsic_ba = [subsetpath '/OUTPUT/intrinsic_ba.csv'];
    
    % lens distortion estimation
    set.lensDistortion = [subsetpath '/OUTPUT/lensDistortion.csv'];
    
    % folder content summary
    set.folderContent = [subsetpath '/OUTPUT/folderContent.csv']; 
    
    % sequences summary
    set.sequencesSummary = [subsetpath '/OUTPUT/sequencesSummary.csv']; 
        
    % exposure summary
    set.exposuresSummary = [subsetpath '/OUTPUT/exposuresSummary.csv']; 
    
    % matched stars summary
    set.allStarSummary = [subsetpath '/OUTPUT/allStarSummary.csv']; 

    % star filtering (using brightness, 
    set.inlierStarSummary = [subsetpath '/OUTPUT/inlierStarSummary.csv']; 
end
