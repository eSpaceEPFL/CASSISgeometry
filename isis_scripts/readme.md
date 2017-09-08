## Some scripts that simplify processing of CaSSIS data

** Prerequisits: **

1 install python2.7
2 install opencv
3 install usgs isis
4 put all scripts in globally visible folder

** Description **

1 tgocassis_findSeq <cassisFolder>  - given folder produces txt files with list of subexposures for each band and each sequence.
2 tgocassis_colorMosaic <band1.lis> <band2.lis> <band3.lis> <mosaic.cub> - given list of subexposures for each band of the sequence produces mosaic cube
