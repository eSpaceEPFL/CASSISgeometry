DATASET_PATH="/home/tulyakov/Desktop/espace-server/CASSIS/aerobraking/161122_periapsis_orbit09"
INPUT_PATH=$DATASET_PATH/level1_corr
tgocassis_findSeq.py $INPUT_PATH

tgocassis_mosaic.py $INPUT_PATH/seq7_RED.lis $DATASET_PATH/OUTPUT_ISIS/tosend/seq7_RED.cub
isis2std red=$DATASET_PATH/OUTPUT_ISIS/tosend/seq7_RED.cub+1 green=$DATASET_PATH/OUTPUT_ISIS/tosend/seq7_RED.cub+1 blue=$DATASET_PATH/OUTPUT_ISIS/tosend/seq7_RED.cub+1 to=$DATASET_PATH/OUTPUT_ISIS/tosend/seq7_RED.tif mode=rgb format=tiff bittype=8bit 
