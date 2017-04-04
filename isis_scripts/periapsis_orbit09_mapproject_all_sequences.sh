DATASET_PATH="/home/tulyakov/Desktop/espace-server/CASSIS/aerobraking/161122_periapsis_orbit09"
INPUT_PATH=$DATASET_PATH/level1_corr
tgocassis_findSeq.py $INPUT_PATH

tgocassis_colorMosaic.py $INPUT_PATH/seq0_RED.lis $INPUT_PATH/seq0_RED.lis $INPUT_PATH/seq0_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq0_RED_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq0_RED_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq0_RED_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq0_RED_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq0_RED_RED_RED.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $INPUT_PATH/seq1_RED.lis $INPUT_PATH/seq1_NIR.lis $INPUT_PATH/seq1_BLU.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq1_RED_NIR_BLU.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq1_RED_NIR_BLU.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq1_RED_NIR_BLU.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq1_RED_NIR_BLU.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq1_RED_NIR_BLU.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $INPUT_PATH/seq2_RED.lis $INPUT_PATH/seq2_NIR.lis $INPUT_PATH/seq2_BLU.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq2_RED_NIR_BLU.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq2_RED_NIR_BLU.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq2_RED_NIR_BLU.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq2_RED_NIR_BLU.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq2_RED_NIR_BLU.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $INPUT_PATH/seq3_RED.lis $INPUT_PATH/seq3_NIR.lis $INPUT_PATH/seq3_BLU.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq3_RED_NIR_BLU.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq3_RED_NIR_BLU.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq3_RED_NIR_BLU.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq3_RED_NIR_BLU.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq3_RED_NIR_BLU.tif mode=rgb format=tiff bittype=8bit

tgocassis_colorMosaic.py $INPUT_PATH/seq4_PAN.lis $INPUT_PATH/seq4_RED.lis $INPUT_PATH/seq4_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq4_PAN_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq4_PAN_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq4_PAN_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq4_PAN_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq4_PAN_RED_RED.tif mode=rgb format=tiff bittype=8bit

tgocassis_colorMosaic.py $INPUT_PATH/seq5_PAN.lis $INPUT_PATH/seq5_RED.lis $INPUT_PATH/seq5_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq5_PAN_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq5_PAN_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq5_PAN_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq5_PAN_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq5_PAN_RED_RED.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $INPUT_PATH/seq6_PAN.lis $INPUT_PATH/seq6_RED.lis $INPUT_PATH/seq6_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq6_PAN_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq6_PAN_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq6_PAN_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq6_PAN_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq6_PAN_RED_RED.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $INPUT_PATH/seq7_PAN.lis $INPUT_PATH/seq7_RED.lis $INPUT_PATH/seq7_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq7_PAN_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq7_PAN_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq7_PAN_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq7_PAN_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq7_PAN_RED_RED.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $INPUT_PATH/seq8_PAN.lis $INPUT_PATH/seq8_PAN.lis $INPUT_PATH/seq8_PAN.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq8_PAN_PAN_PAN.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq8_PAN_PAN_PAN.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq8_PAN_PAN_PAN.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq8_PAN_PAN_PAN.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq8_PAN_PAN_PAN.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $INPUT_PATH/seq9_RED.lis $INPUT_PATH/seq9_NIR.lis $INPUT_PATH/seq9_BLU.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq9_RED_NIR_BLU.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq9_RED_NIR_BLU.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq9_RED_NIR_BLU.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq9_RED_NIR_BLU.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq9.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $INPUT_PATH/seq10_PAN.lis $INPUT_PATH/seq10_RED.lis $DATASE_PAT/level1/seq10_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq10_PAN_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq10_PAN_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq10_PAN_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq10_PAN_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq10_PAN_RED_RED.tif mode=rgb format=tiff bittype=8bit
