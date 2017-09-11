## Scripts that simplify pre-processing of CaSSIS data

**Prerequisits:**

* Install python2.7
* Install opencv for python
* Install usgs isis
* Put all scripts in globally visible folder

**Description**

* _tgocassis_findSeq_ <cassisFolder>  - given folder produces txt files with list of subexposures for each band and each sequence.
* _tgocassis_colorMosaic_ <band1.lis> <band2.lis> <band3.lis> <mosaic.cub> - given list of subexposures for each band of the sequence produces mosaic cube
