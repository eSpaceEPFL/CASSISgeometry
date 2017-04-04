#!/HDD1/Programs/anaconda2/bin/python -tt
import os
import glob
import shutil
import sys

def main():
    
    if len(sys.argv) < 3:
       print('tgocassis_corrBandsShift_folder.py <ifolder.lis>  <ofolder.cub>')
       print('<ifolder> is an input folder with cassis cub\n' \
             '<ofolder> is an output folder ')
       sys.exit()

    ifolder = sys.argv[1]
    ofolder = sys.argv[2]
    
    if ifolder == ofolder:
        print('input and output folders should be different')
        sys.exit()

    filelist = glob.glob(ifolder + '/*.cub')
    for file in filelist:
        print file
        nameWoExt, ext = os.path.splitext(os.path.basename(file))        
        execStr = 'tgocassis_corrBandsShift.py %s %s/%s.cub' % (file, ofolder, nameWoExt)
        print 'Calling %s' % execStr
        os.system(execStr)

        execStr = 'isis2std red=%s/%s.cub+1 green=%s/%s.cub+2 blue=%s/%s.cub+3 to=%s/%s.tif mode=rgb format=tiff bittype=8bit' % ( ofolder, nameWoExt,  ofolder, nameWoExt,  ofolder, nameWoExt,  ofolder, nameWoExt)
        print 'Calling %s' % execStr
        os.system(execStr)
        
    
if  __name__ == '__main__':
    main()