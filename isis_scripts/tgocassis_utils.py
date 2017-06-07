import sys
import re
import os
import fnmatch
import numpy as np
import cv2 
from datetime import datetime
import matplotlib.pyplot as plt

def getinfo_subExp(xml_fname):

    f = open(xml_fname,'r')
    win_counter_pattern = 'WindowCounter="(\d)"'
    win_start_row_pattern = 'Window%i_Start_Row="(\d+)"'
    win_end_row_pattern = 'Window%i_End_Row="(\d+)"'
    win_start_col_pattern = 'Window%i_Start_Col="(\d+)"'
    win_end_col_pattern = 'Window%i_End_Col="(\d+)"'
    info = {}
    if f:
        data = f.read()
        m = re.search(win_counter_pattern, data)
        info['win_num'] = int(m.group(1)) + 1
        m = re.search(win_start_row_pattern % info['win_num'], data)
        info['win_row0'] = int(m.group(1)) + 1
        m = re.search(win_end_row_pattern % info['win_num'], data)
        info['win_rowE'] = int(m.group(1)) + 1
        m = re.search(win_start_col_pattern % info['win_num'], data)
        info['win_col0'] = int(m.group(1)) + 1
        m = re.search(win_end_col_pattern % info['win_num'], data)
        info['win_colE'] = int(m.group(1)) + 1
    else:
        print('Can not open %s' % xml_fname)
    f.close()
    return info


def find_imshift(trg_im, src_im):

    # find dx and dy to add to src_im to get trg_im
    sift = cv2.xfeatures2d.SIFT_create()
    bf = cv2.BFMatcher()

    kpTrg, desTrg = sift.detectAndCompute(trg_im, None)
    kpSrc, desSrc = sift.detectAndCompute(src_im, None)
    matches = bf.knnMatch(desTrg, desSrc, k=1)
    dx = []
    dy = []
    for match in matches:
        dx.append(kpTrg[match[0].queryIdx].pt[0] -
                  kpSrc[match[0].trainIdx].pt[0])
        dy.append(kpTrg[match[0].queryIdx].pt[1] -
                  kpSrc[match[0].trainIdx].pt[1])
    dx_med = np.median(np.array(dx))
    dy_med = np.median(np.array(dy))

    return dx_med, dy_med

def write_subExp(im, dat_fname):

    h, w = im.shape
    f = open(dat_fname, 'wb')
    if f:
        # level1 - float (32bit), level0 - uint16
        raw_data = im.reshape((h * w))
        raw_data.astype(np.float32).tofile(f)
        f.close()
        return True
    else:
        print('Can not open %s' % dat_fname)
        return False

def read_subExp(xml_fname):

    dat_fname = xml_fname[:-4] + '.dat'
    print(dat_fname)
    info = getinfo_subExp(xml_fname)
    w = info['win_colE'] - info['win_col0'] + 1
    h = info['win_rowE'] - info['win_row0'] + 1
    im = []
    f = open(dat_fname, 'rb')
    if f:
        # level1 - float (32bit), level0 - uint16
        raw_data = np.fromfile(f, dtype=np.float32, count=-1)
        h_actual = raw_data.size / w
        if( h_actual < h ):
            print('dataloss detected')
        im = raw_data.reshape((h_actual, w))
        f.close()
    else:
        print('Can not open %s' % xml_fname)
    return (im, info)

def time_str2timeobj(timeStr): return datetime.strptime(timeStr, '%Y-%m-%dT%H.%M.%S.%f')

def num2type_subExp(num): 
    code = ['PAN', 'RED', 'NIR', 'BLU']
    return code[num]

def split_filesBySubExp(subExp_filenames):
    
    # 0-PAN, 1-RED, 2-NIR, 3-BLU 
    subExpList = [[],[],[],[]]
    for file in subExp_filenames:
        info = parse_subExp_filename(file)
        subExp = int(info[2])
        subExpList[subExp].append(file) 
    
    return subExpList

def split_filesBySeq(subExp_filenames):

    # sort by time
    def sort_by_time(fileName):
        info = parse_subExp_filename(fileName)
        timeStr = info[1]
        timeObj = time_str2timeobj(timeStr)
        return timeObj

    subExp_filenames = sorted(subExp_filenames, key=sort_by_time)

    nSeq = 1;
    prev_nExp = 0;
    seqFilesList = []
    seqList = []
    for file in subExp_filenames:
        info = parse_subExp_filename(file)
        nExp = int(info[3])
        if( nExp < prev_nExp ):
            seqList.append(seqFilesList)
            seqFilesList = [] 
            nSeq = nSeq + 1
            seqFilesList.append(file)
        else:
            seqFilesList.append(file)
        prev_nExp = nExp;
    seqList.append(seqFilesList)
    return seqList


def find_xmlFiles(path):
    fileTab = []
    for file in os.listdir(path):
        if not fnmatch.fnmatch(file, '*.xml'): continue
        fileTab.append(file)
    return fileTab

def parse_subExp_filename(subExp_filename):
    pattern = '\w+-\w+-(\d\d\d\d-\d\d-\d\dT\d\d.\d\d.\d\d.\d\d\d)-\w+-(\d\d)(\d\d\d)-\w+.xml'
    match = re.search(pattern, subExp_filename)
    if match :
        timeStr = match.group(1)
        subExpN = match.group(2)
        expN = match.group(3)
    else :
        print('failed to parse filename %s', subExp_filename)
        sys.exit()
    return (subExp_filename, timeStr, subExpN, expN)

def write_lines_list(fname, lines_list):
    f = open(fname,'w')
    if f:
        for item in lines_list:
            f.write("%s\n" % item)
        f.close()
        return True
    else:
        print('can not open %s' % fname)
        return False

def read_lines_list(fname):
    f = open(fname)
    if f:
        list = f.read().splitlines()
        f.close()
        return list
    else:
        print('can not open %s' % fname)
        sys.exit()
        return []

def subexp2sensor(x_subexp, y_subexp, x0, y0):
    x_sensor = x_subexp + x0 - 1  
    y_sensor = y_subexp + y0 - 1
    return (x_sensor, y_sensor)

def sensor2subexp(x_sensor, y_sensor, x0, y0):
    x_subexp = x_sensor - x0 + 1   
    y_subexp = y_sensor - y0 + 1
    return (x_subexp, y_subexp)

def sensor2front(x_sensor, y_sensor, image_height = 2048):
    x_front = x_sensor.copy()
    y_front = image_height - y_sensor + 1
    return (x_front, y_front)

def front2sensor(x_front, y_front, image_height = 2048):
    x_sensor = x_front.copy()
    y_sensor = image_height - y_front + 1
    return (x_sensor, y_sensor)

def pixel2norm(x_pixel, y_pixel, image_width = 2048, image_height = 2048):
    norm = image_height + image_width;
    x_norm = (x_pixel - image_width  / 2) / norm
    y_norm = (y_pixel - image_height / 2) / norm
    return (x_norm, y_norm)

def norm2pixel(x_norm, y_norm, image_width = 2048, image_height = 2048):
    norm = image_height + image_width;
    x_pixel = (x_norm * norm + image_width / 2)
    y_pixel = (y_norm * norm + image_height / 2)
    return (x_pixel, y_pixel)

def lift_to_6D(x_vec, y_vec):
    if x_vec.shape[1] == 1 and y_vec.shape[1] == 1:
        points_6D = np.concatenate((np.power(x_vec,2), np.multiply(x_vec, y_vec), np.power(y_vec, 2), x_vec, y_vec, np.ones((x_vec.size, 1))), axis=1 )
    else:
        print('x_vec and y_vec should be n x 1 vectors')
        sys.exit()
    return points_6D

def imadjust(im, minVal = None, maxVal = None):
    if maxVal == None :
        maxVal = im.max()
    if minVal == None :
        minVal = im.min()
    rangeVal = maxVal - minVal
    im = (im - minVal) / rangeVal
    return im

def undistort(subexp, x0, y0, Acorr2dist):

    subexp_height, subexp_width = subexp.shape
    x_range = np.arange(1, subexp_width + 1, dtype='float32')
    y_range = np.arange(1, subexp_height + 1, dtype='float32')
    [xx_subexp, yy_subexp] = np.meshgrid(x_range, y_range)

    xx_subexp = xx_subexp.reshape(xx_subexp.size, 1)
    yy_subexp = yy_subexp.reshape(yy_subexp.size, 1)
    xx_sensor, yy_sensor = subexp2sensor(xx_subexp, yy_subexp, x0, y0)
    xx_front, yy_front = sensor2front(xx_sensor, yy_sensor)
    
    xx_norm, yy_norm = pixel2norm(xx_front, yy_front)

    pnts6D = lift_to_6D(xx_norm, yy_norm)
    
    vec = np.dot(pnts6D, Acorr2dist.T)
    dist_xx_norm = np.divide(vec[:, 0], vec[:, 2])
    dist_yy_norm = np.divide(vec[:, 1], vec[:, 2])
    
    dist_xx_front, dist_yy_front = norm2pixel(dist_xx_norm, dist_yy_norm)
    dist_xx_sensor, dist_yy_sensor = front2sensor(dist_xx_front, dist_yy_front)
    dist_xx_subexp, dist_yy_subexp = sensor2subexp(dist_xx_sensor, dist_yy_sensor, x0, y0)

    
    dist_xx_subexp = dist_xx_subexp.reshape(subexp_height, subexp_width)
    dist_yy_subexp = dist_yy_subexp.reshape(subexp_height, subexp_width)

    subexp_corr = cv2.remap(subexp.astype('float32'), dist_xx_subexp.astype('float32'), dist_yy_subexp.astype('float32'), cv2.INTER_CUBIC, cv2.BORDER_REFLECT_101)
    mask = np.ones(subexp_corr.shape, dtype=bool)
    mask[0:4,:] = 0
    mask[:,0:4] = 0
    mask[-5:,:] = 0
    mask[:,-5:] = 0
    subexp_corr[~mask] = float('inf')

    return  subexp_corr, mask

if  __name__ == '__main__':
    main()