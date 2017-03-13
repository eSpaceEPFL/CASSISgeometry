function set = DATASET_starfields(dataset_path, subset_name)

    set.name = subset_name;
        
    % Function returns all folder pertained to CaSSIS starfield dataset
	 warning ('off','all'); % to prevent warnings on folder creation
    
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
    
    elseif( strcmp('mcc_motor_pointing_cassis', subset_name) )
   
        subsetpath = [dataset_path '/CASSIS/tests/mcc_motor_pointing_cassis'];
        
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
    
    mkdir(subsetpath,  'OUTPUT');
        
    % combined frames
    set.sequences = [subsetpath '/OUTPUT/sequences'];
    mkdir([subsetpath '/OUTPUT/'], 'sequences');
    
    set.raw_exposures = [subsetpath '/OUTPUT/raw_exposures'];
    mkdir([subsetpath '/OUTPUT/'], 'raw_exposures');
    
    % denoised exposures
    set.denoise_exposure = [subsetpath '/OUTPUT/denoise_exposures'];
    mkdir([subsetpath '/OUTPUT/'],  'denoise_exposures');
    
    % recognized stars
    set.recognize = [subsetpath '/OUTPUT/recognize']; 
    mkdir([subsetpath '/OUTPUT/'], 'recognize');
    
    % ----------- summaries -------------

    % factory parameters
    set.intrinsic0 = [subsetpath '/OUTPUT/intrinsic0.csv'];
    set.lensDistortion0 = [subsetpath '/OUTPUT/lensDistortion0.csv'];
    set.extrinsic0_spice = [subsetpath '/OUTPUT/extrinsic0_spice.csv'];
    
    % individual rotation angle tuning
    set.extrinsic0_local = [subsetpath '/OUTPUT/extrinsic0_local.csv'];
    set.local_vs_spice_angel_diff_IMG = [subsetpath '/OUTPUT/local_vs_spice_angle_diff.png'];
    set.local_vs_spice_proj_err_IMG = [subsetpath '/OUTPUT/local_vs_spice_proj_err.png'];
    set.ange_vs_angel_diff_IMG = [subsetpath '/OUTPUT/ange_vs_angel_diff.png'];
    
    
    % BA parameters
    set.extrinsic_ba = [subsetpath '/OUTPUT/extrinsic_ba.csv'];
    set.intrinsic_ba = [subsetpath '/OUTPUT/intrinsic_ba.csv'];
    set.ba_residuals_IMG = [subsetpath '/OUTPUT/ba_residuals%i.png']; 
    
    % commanded rotation
    set.sysRotErr = [subsetpath '/OUTPUT/sysRotErr.csv'];
    
    % commanded rotation
    set.rotCommand = [subsetpath '/OUTPUT/rotCommand.csv'];
    
    % lens distortion estimation
    set.lensDistortion = [subsetpath '/OUTPUT/lensDistortion.csv'];
    set.lensDistortion_field_IMG = [subsetpath '/OUTPUT/lensDistortion_field.png'];
    set.lensDistortion_residuals_IMG = [subsetpath '/OUTPUT/lensDistortion_residuals.png'];
    
    % final parameters
    set.intrinsic_final = 'intrinsic_final.csv';
    set.lensDistortion_final ='lensDistortion_final.csv';
    set.sysRotErr_final = 'sysRotErr_final.csv';
    
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
    set.inlierStarSummary_IMG = [subsetpath '/OUTPUT/allStarSummary.png']; 
    
    
     warning ('on','all');
end
