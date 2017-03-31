DATASET_PATH="/home/tulyakov/Desktop/espace-server/CASSIS/aerobraking/161122_periapsis_orbit09"
tgocassis_findSeq.py $DATASET_PATH/level1

tgocassis_colorMosaic.py $DATASET_PATH/level1/seq0_RED.lis $DATASET_PATH/level1/seq0_RED.lis $DATASET_PATH/level1/seq0_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq0_RED_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq0_RED_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq0_RED_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq0_RED_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq0_RED_RED_RED.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $DATASET_PATH/level1/seq1_RED.lis $DATASET_PATH/level1/seq1_NIR.lis $DATASET_PATH/level1/seq1_BLU.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq1_RED_NIR_BLU.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq1_RED_NIR_BLU.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq1_RED_NIR_BLU.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq1_RED_NIR_BLU.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq1_RED_NIR_BLU.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $DATASET_PATH/level1/seq2_RED.lis $DATASET_PATH/level1/seq2_NIR.lis $DATASET_PATH/level1/seq2_BLU.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq2_RED_NIR_BLU.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq2_RED_NIR_BLU.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq2_RED_NIR_BLU.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq2_RED_NIR_BLU.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq2_RED_NIR_BLU.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $DATASET_PATH/level1/seq3_RED.lis $DATASET_PATH/level1/seq3_NIR.lis $DATASET_PATH/level1/seq3_BLU.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq3_RED_NIR_BLU.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq3_RED_NIR_BLU.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq3_RED_NIR_BLU.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq3_RED_NIR_BLU.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq3_RED_NIR_BLU.tif mode=rgb format=tiff bittype=8bit

tgocassis_colorMosaic.py $DATASET_PATH/level1/seq4_PAN.lis $DATASET_PATH/level1/seq4_RED.lis $DATASET_PATH/level1/seq4_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq4_PAN_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq4_PAN_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq4_PAN_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq4_PAN_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq4_PAN_RED_RED.tif mode=rgb format=tiff bittype=8bit

tgocassis_colorMosaic.py $DATASET_PATH/level1/seq5_PAN.lis $DATASET_PATH/level1/seq5_RED.lis $DATASET_PATH/level1/seq5_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq5_PAN_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq5_PAN_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq5_PAN_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq5_PAN_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq5_PAN_RED_RED.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $DATASET_PATH/level1/seq6_PAN.lis $DATASET_PATH/level1/seq6_RED.lis $DATASET_PATH/level1/seq6_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq6_PAN_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq6_PAN_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq6_PAN_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq6_PAN_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq6_PAN_RED_RED.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $DATASET_PATH/level1/seq7_PAN.lis $DATASET_PATH/level1/seq7_RED.lis $DATASET_PATH/level1/seq7_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq7_PAN_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq7_PAN_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq7_PAN_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq7_PAN_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq7_PAN_RED_RED.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $DATASET_PATH/level1/seq8_PAN.lis $DATASET_PATH/level1/seq8_PAN.lis $DATASET_PATH/level1/seq8_PAN.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq8_PAN_PAN_PAN.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq8_PAN_PAN_PAN.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq8_PAN_PAN_PAN.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq8_PAN_PAN_PAN.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq8_PAN_PAN_PAN.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $DATASET_PATH/level1/seq9_RED.lis $DATASET_PATH/level1/seq9_NIR.lis $DATASET_PATH/level1/seq9_BLU.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq9_RED_NIR_BLU.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq9_RED_NIR_BLU.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq9_RED_NIR_BLU.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq9_RED_NIR_BLU.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq9.tif mode=rgb format=tiff bittype=8bit 

tgocassis_colorMosaic.py $DATASET_PATH/level1/seq10_PAN.lis $DATASET_PATH/level1/seq10_RED.lis $DATASE_PAT/level1/seq10_RED.lis $DATASET_PATH/OUTPUT_ISIS/mosaic/seq10_PAN_RED_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq10_PAN_RED_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq10_PAN_RED_RED.cub+2 blue=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq10_PAN_RED_RED.cub+3 to=$DATASET_PATH/OUTPUT_ISIS/mosaic/seq10_PAN_RED_RED.tif mode=rgb format=tiff bittype=8bit
