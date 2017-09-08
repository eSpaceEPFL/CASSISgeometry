#!/HDD1/Programs/anaconda2/bin/python -tt

import sys
import re
import tempfile
import os
import shutil
import tgocassis_utils as tgo
import commands

def main():

    if len(sys.argv) < 3:
        print('tgocassis_colorMosaic <band1.lis> <band2.lis> <band3.lis> <mosaic.cub>')
        print('<band1.lis> <band2.lis> <band3.lis> are files that contain list of datastripe files for every band\n' \
              '<mosaic.cub> is output cube with mosaic')
        sys.exit()

    band_nb = len(sys.argv) - 2
    input_list = []
    for nband in range(1, band_nb + 1): input_list.append(sys.argv[nband]) 
    mosaic = sys.argv[-1] 

    tmp_dir = tempfile.mkdtemp()
    print tmp_dir
    input_dir = os.path.dirname(input_list[0])

    for nband in range(0, band_nb):
        
        exe_str = 'tgocassis2isis from=%s/\$1.xml to=%s/\$1.cub -batchlist=%s' % (input_dir, tmp_dir, input_list[nband])
        print 'Calling %s' % exe_str
        os.system(exe_str)
            
        exe_str = 'spiceinit from=%s/\$1.cub ckp=t spkp=t -batchlist=%s' % (tmp_dir, input_list[nband])
        print 'Calling %s' % exe_str
        os.system(exe_str)

    exe_str ='ls %s/*cub > %s/cubes.lis' % (tmp_dir, tmp_dir)
    print 'Calling %s' % exe_str
    os.system(exe_str)
        
    exe_str = 'mosrange fromlist=%s/cubes.lis to=%s/equi.map proj=Equirectangular' % (tmp_dir, tmp_dir)
    print 'Calling %s' % exe_str
    os.system(exe_str)
    map = '%s/equi.map' % tmp_dir

    minLat_list = [0] * band_nb
    minLon_list = [0] * band_nb
    maxLat_list = [0] * band_nb
    maxLon_list = [0] * band_nb

    for nband in range(0, band_nb):

        exe_str = 'cam2map from=%s/\$1.cub map=%s pixres=map to=%s/\$1.band%i.map.cub -batchlist=%s' % (tmp_dir, map, tmp_dir, nband, input_list[nband])
        print 'Calling %s' % exe_str
        os.system(exe_str)

        exe_str ='ls %s/*band%i.map.cub > %s/band%i.mapcubes.lis' % (tmp_dir, nband, tmp_dir,  nband)
        print 'Calling %s' % exe_str
        os.system(exe_str)

        exe_str ='automos fromlist=%s/band%i.mapcubes.lis mosaic=%s/band%i.mosaic' % (tmp_dir, nband,  tmp_dir,nband) 
        print 'Calling %s' % exe_str
        os.system(exe_str)

        # find cube extent
        _,minLat_list[nband] = commands.getstatusoutput('getkey from=%s/band%i.mosaic.cub grpname=Mapping keyword=MinimumLatitude' % (tmp_dir,nband))
        _,maxLat_list[nband] = commands.getstatusoutput('getkey from=%s/band%i.mosaic.cub grpname=Mapping keyword=MaximumLatitude' % (tmp_dir,nband))
        _,minLon_list[nband] = commands.getstatusoutput('getkey from=%s/band%i.mosaic.cub grpname=Mapping keyword=MinimumLongitude' % (tmp_dir,nband))
        _,maxLon_list[nband] = commands.getstatusoutput('getkey from=%s/band%i.mosaic.cub grpname=Mapping keyword=MaximumLongitude' % (tmp_dir,nband))

    maxLon_list = [float(i) for i in maxLon_list]
    maxLat_list = [float(i) for i in maxLat_list]
    minLon_list = [float(i) for i in minLon_list]
    minLat_list = [float(i) for i in minLat_list]
    
    minLon = max(minLon_list)
    minLat = max(minLat_list)
    maxLon = min(maxLon_list)
    maxLat = min(maxLat_list)

    for nband in range(0, band_nb):
        exe_str ='maptrim from=%s/band%i.mosaic.cub to=%s/band%i.mosaic.trim.cub mode=crop minlat=%f maxlat=%f minlon=%f maxlon=%f' % (tmp_dir, nband, tmp_dir, nband, minLat, maxLat, minLon, maxLon)
        print 'Calling %s' % exe_str
        os.system(exe_str)

    exe_str ='ls %s/band?.mosaic.trim.cub > %s/mosaicCubes.lis' % (tmp_dir, tmp_dir)
    print 'Calling %s' % exe_str
    os.system(exe_str)
    
    execStr ='cubeit fromlist=%s/mosaicCubes.lis to=%s' % (tmp_dir, mosaic) 
    print 'Calling %s' % execStr
    os.system(execStr)

    shutil.rmtree(tmp_dir) 

    return 1

if  __name__ == '__main__':
    main()
