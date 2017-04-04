#!/HDD1/Programs/anaconda2/bin/python -tt

import sys
import re
import tempfile
import os
import shutil
import tgocassis_utils as tgo
        
def main():

    if len(sys.argv) < 5:
        print('tgocassis_colorMosaic <band1.lis> <band2.lis> <band3.lis> <mosaic.cub>')
        print('<band1.lis> <band2.lis> <band3.lis> are files that contain list of datastripe files for every band\n' \
              '<mosaic.cub> is output cube with mosaic')
        sys.exit()

    band1_fname = sys.argv[1]
    band2_fname = sys.argv[2]
    band3_fname = sys.argv[3]
    mosaic_fname = sys.argv[4]

    tmpDir =  tempfile.mkdtemp()

    execStr = 'tgocassis_mosaic.py %s  %s/band1mosaic.cub' % (band1_fname, tmpDir)
    print 'Calling %s' % execStr
    os.system(execStr)

    execStr = 'tgocassis_mosaic.py %s  %s/band2mosaic.cub' % (band2_fname, tmpDir)
    print 'Calling %s' % execStr
    os.system(execStr)
    
    execStr = 'tgocassis_mosaic.py %s  %s/band3mosaic.cub' % (band3_fname, tmpDir)
    print 'Calling %s' % execStr
    os.system(execStr)

    execStr ='map2map from=%s/band2mosaic.cub to= %s/band2mosaic.match.cub map=%s/band1mosaic.cub matchmap=yes' % (tmpDir, tmpDir, tmpDir) 
    print 'Calling %s' % execStr
    os.system(execStr)

    execStr ='map2map from=%s/band3mosaic.cub to= %s/band3mosaic.match.cub map=%s/band1mosaic.cub matchmap=yes' % (tmpDir, tmpDir, tmpDir) 
    print 'Calling %s' % execStr
    os.system(execStr)

    colorList = ['%s/band1mosaic.cub' % tmpDir, '%s/band2mosaic.match.cub'% tmpDir, '%s/band3mosaic.match.cub'% tmpDir]
    print colorList
    tgo.write_lines_list('%s/mosaicCubes.lis' % (tmpDir), colorList)
    execStr ='cubeit fromlist=%s/mosaicCubes.lis to=%s' % (tmpDir, mosaic_fname) 
    print 'Calling %s' % execStr
    os.system(execStr)

    shutil.rmtree(tmpDir) 

    return 1

if  __name__ == '__main__':
    main()