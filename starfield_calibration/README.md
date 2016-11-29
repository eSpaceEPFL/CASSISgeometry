# Starfield calibration
Repository contains code for geometric calibration of CaSSIS using starfield data

## Prerequisits
Before using this code you need to preinstall:

1. Matlab 2015b 
2. [MICE library](https://naif.jpl.nasa.gov/naif/toolkit.html "MICE library") 
3. [Astrometry library](http://astrometry.net/use.html "Astrometry library")

The calibration procedure is described in "Technical Report: Geometric calibration of CaSSIS using star-field images" that you can find in doc folder.

## Process
For convenience calibration procedure consists of several scripts: 

1. SCRIPT_cassis2raw.m - assembles images from packages. 
2. SCRIPT_denoise.m - dark frame substraction and flattening. 		
3. SCRIPT_recognize.m - stars recognition using Astrometry library.
4. SCRIPT_collect.m - collect information from all recognized starfield.
5. SCRIPT_filter_outliers.m - remain only  stars that are re-detected in several frames.  
6. SCRIPT_divide_set.m - divide stars in test set and train set.
7. SCRIPT_init_extrinsic.m - initialize rotation matrices for every image individiually.
8. SCRIPT_solve_camera.m - find camera parameters without considering lens distortions.
9. SCRIPT_solve_distortion.m - find lens distortions.
10. SCRIPT_evaluate_rotation.m - evaluate how precise is rotation mechanism.
