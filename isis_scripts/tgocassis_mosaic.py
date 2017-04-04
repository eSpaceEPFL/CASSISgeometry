#!/HDD1/Programs/anaconda2/bin/python -tt


import sys
import re
import tempfile
import os
import shutil
import tgocassis_utils as tgo
        
def main():
    if len(sys.argv) < 3:
        print('tgocassis_mosaic <subexp.lis>  <mosaic.cub>')
        print('<subexp.lis> is a file that contains name of cassis xml files on every line\n' \
              '<mosaic.cub> is output cube with mosaic' \
              '<map.cub> is optional map parameter')
        sys.exit()

    subExp_list_fname = sys.argv[1]
    expDir = os.path.dirname(subExp_list_fname)

    mosaic_fname = sys.argv[2]
    if  len(sys.argv) < 4:
        map_fname = None
    else:
        map_fname = sys.argv[3]

    subExp_fnames = tgo.read_lines_list(subExp_list_fname)
    print('%i files were found in the list:' % len(subExp_fnames))
    for item in subExp_fnames: print(item)
    
    tmpDir = tempfile.mkdtemp()
    
    cubeList = []
    for subExp_fname in subExp_fnames :

        print('Start processing %s' % subExp_fname)
        nameWoExt, ext = os.path.splitext(subExp_fname)
        
        execStr = 'tgocassis2isis from=%s/%s.xml to=%s/%s.cub' % (expDir, nameWoExt, tmpDir, nameWoExt)
        print 'Calling %s' % execStr
        os.system(execStr)
        
        execStr = 'spiceinit from=%s/%s.cub ckpredict=true spkpredict=true' % (tmpDir, nameWoExt)
        print 'Calling %s' % execStr
        os.system(execStr)
        
        if map_fname is None:
            execStr = 'cam2map from=%s/%s.cub to=%s/%s.mapsin.cub' % (tmpDir, nameWoExt, tmpDir, nameWoExt)
            map_fname = '%s/%s.mapsin.cub' %  (tmpDir, nameWoExt)
        else:
            execStr = 'cam2map from=%s/%s.cub to=%s/%s.mapsin.cub map=%s pixres=map' % (tmpDir, nameWoExt, tmpDir, nameWoExt, map_fname)
            
        print 'Calling %s' % execStr
        os.system(execStr)

        cubeList.append( tmpDir + '/' + nameWoExt + '.mapsin.cub')

    print('Saving cubes list to file %s/cubes.lis' % (tmpDir))
    tgo.write_lines_list('%s/cubes.lis' % (tmpDir), cubeList)

    execStr ='automos fromlist=%s/cubes.lis mosaic=%s' % (tmpDir, mosaic_fname) 
    print 'Calling %s' % execStr
    os.system(execStr)

    shutil.rmtree(tmpDir) 

    return 1



if  __name__ == '__main__':
    main()