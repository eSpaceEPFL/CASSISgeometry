#!/HDD1/Programs/anaconda2/bin/python -tt

import sys
import numpy as np
import pandas as pd
import tempfile
import os
import time
import shutil
import tgocassis_utils as tgo
import cv2
import matplotlib.pyplot as plt

def main():

    if len(sys.argv) < 3:
        print('tgocassis_undistortSubExp <isubexp.xml> <osubexp.dat> <Acorr2dist.xml>')
        print('<isubexp.xml> input subexposure file \n' \
              '<osubexp.dat> output subexposure file \n' \
              '<A_corr2dist.xml> is output cube with mosaic')
        sys.exit()

    isubexp_fname = sys.argv[1]
    osubexp_fname = sys.argv[2]
    Acorr2dist_fname = sys.argv[3]

    try:
        tab = pd.read_csv(Acorr2dist_fname)
        Acorr2dist = tab.as_matrix()
    except:
        print('failed to read file %s' % (Acorr2dist_fname))
        sys.exit()

    subexp, info = tgo.read_subExp(isubexp_fname)
    (x0, y0) = (info['win_col0'], info['win_row0']) 

    subexp_corr, mask = tgo.undistort(subexp, x0, y0, Acorr2dist)

    print 'subexp: ', subexp.min(), subexp.max()
    print 'subexp_corr: ', subexp_corr.min(), subexp_corr.max()

    tgo.write_subExp(subexp_corr, osubexp_fname)


    return 1

if  __name__ == '__main__':
    main()