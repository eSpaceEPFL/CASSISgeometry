#!/HDD1/Programs/anaconda2/bin/python -tt
import os
import glob
import shutil

def main():
    
    if len(sys.argv) < 3:
       print('tgocassis_undistortSubExp_folder <ifolder.lis>  <ofolder.cub> <Acorr2dist>')
       print('<ifolder> is an input folder with cassis dat and xml files\n' \
             '<ofolder> is an output folder ' \
             '<Acorr2dist.csv> is csv file with rational distortion matrix')
       sys.exit()

    ifolder = sys.argv[1]
    ofolder = sys.argv[2]
    Acorr2dist_fname = sys.argv[3]

    if ifolder == ofolder:
        print('input and output folders should be different')
        sys.exit()

    filelist = glob.glob(ifolder + '/*.xml')
    for file in filelist:
        print file
        nameWoExt, ext = os.path.splitext(os.path.basename(file))        
        execStr = 'tgocassis_undistortSubExp.py %s  %s/%s %s' % (file[:-4], ofolder, nameWoExt, Acorr2dist_fname)
        print 'Calling %s' % execStr
        os.system(execStr)
        shutil.copyfile(file, '%s/%s.xml' % (ofolder, nameWoExt))
    
if  __name__ == '__main__':
    main()