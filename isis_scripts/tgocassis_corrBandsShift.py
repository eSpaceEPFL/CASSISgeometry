#!/HDD1/Programs/anaconda2/bin/python -tt

import sys
import re
import tempfile
import os
import shutil
import cv2
import numpy as np
import tgocassis_utils as tgo

def main():
    if len(sys.argv) < 3:
        print('tgocassis_corrBandsShift <input.cub> <output.cub>')
        sys.exit()

    icub_fname = sys.argv[1]
    ocub_fname = sys.argv[2]

    tmpDir = tempfile.mkdtemp()

    # save as tif file in temp dir
    iTif_fname = os.path.join(tmpDir, 'iTif.tif' )
    execStr = 'isis2std red=%s+1 green=%s+2 blue=%s+3 to=%s mode=rgb format=tiff bittype=8bit' % (icub_fname, icub_fname, icub_fname, iTif_fname)
    print 'Calling %s' % execStr
    os.system(execStr)

    # load and compute shifts between channels
    im = cv2.imread(iTif_fname)
    if im == []:
        print('Cant open %s ' % iTif_fname)
        sys.exit()

    b, g, r = cv2.split(im)

    oChCub_fnameS = []
    oChCub_fname = os.path.join(tmpDir, 'R.cub') 
    oChCub_fnameS.append(oChCub_fname)
    execStr = 'translate from=%s+1 to=%s strans=0 ltrans=0' % (icub_fname, oChCub_fname)
    print 'Calling %s' % execStr
    os.system(execStr)

    dx, dy = tgo.find_imshift(r, g)
    print('Channel g shifted w.r.t. channel r by dx = %f, dy = %f' % (dx, dy))
    oChCub_fname = os.path.join(tmpDir, 'G.cub') 
    oChCub_fnameS.append(oChCub_fname)
    execStr = 'translate from=%s+2 to=%s strans=%f ltrans=%f' % (icub_fname, oChCub_fname, dx, dy)
    print 'Calling %s' % execStr
    os.system(execStr)

    dx, dy = tgo.find_imshift(r, b)
    print('Channel b shifted w.r.t. channel r by dx = %f, dy = %f' % (dx, dy))
    oChCub_fname = os.path.join(tmpDir, 'B.cub') 
    oChCub_fnameS.append(oChCub_fname)
    execStr = 'translate from=%s+3 to=%s strans=%f ltrans=%f' % (icub_fname, oChCub_fname, dx, dy)
    print 'Calling %s' % execStr
    os.system(execStr)

    cubList_fname = os.path.join(tmpDir, 'cubes.lis') 
    tgo.write_lines_list(cubList_fname, oChCub_fnameS)
    execStr ='cubeit fromlist=%s to=%s' % (cubList_fname, ocub_fname) 
    print 'Calling %s' % execStr
    os.system(execStr)

    shutil.rmtree(tmpDir) 

    return 1



if  __name__ == '__main__':
    main()