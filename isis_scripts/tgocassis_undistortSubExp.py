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
        print('tgocassis_undistortSubExp <input> <output> <Acorr2dist.csv>')
        print('<input_framelet> input subexposure file \n' \
              '<output_framelet> output subexposure file \n' \
              '<A_corr2dist.xml> is correct2distorted rational matrix')
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

    subexp, info = tgo.read_subExp(isubexp_fname + '.xml')
    (x0, y0) = (info['win_col0'], info['win_row0']) 

    subexp_corr, mask = tgo.undistort(subexp, x0, y0, Acorr2dist)

    print 'subexp: ', subexp.min(), subexp.max()
    print 'subexp_corr: ', subexp_corr.min(), subexp_corr.max()
  #  imwrite('subexp.png', tgo.)

    tgo.write_subExp(subexp_corr, osubexp_fname + '.dat')


    return 1

if  __name__ == '__main__':
    main()