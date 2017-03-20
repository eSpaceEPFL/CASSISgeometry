import sys
import re
import os
import fnmatch
from datetime import datetime

def time_str2timeobj(timeStr): return datetime.strptime(timeStr, '%Y-%m-%dT%H.%M.%S.%f')

def split_filesBySubExp(subExp_filenames):
    
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

if  __name__ == '__main__':
    main()