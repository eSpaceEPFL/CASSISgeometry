#!/usr/bin/python -tt
'''
Function is used to print content of folder with CaSSIS data.
'''

import sys
import re
import os
import shutil
import tgocassis_utils as tgo 

        
def main():
    if len(sys.argv) < 2:
        print('tgocassis_findSeq <cassisFolder>')
        print('<cassisFolder> is a folder with CaSSIS files that we want to summarise\n')
        sys.exit()

    cassisFolder = sys.argv[1]

    xmlFiles = tgo.find_xmlFiles(cassisFolder)
    if not xmlFiles:
        print('There are no files in specified folder') 
        sys.exit()

    xmlFilesBySeq = tgo.split_filesBySeq(xmlFiles)

    for seqXmlFiles in xmlFilesBySeq:
        xmlFilesByBand = tgo.split_filesBySubExp(seqXmlFiles)
        nSeq = xmlFilesBySeq.index(seqXmlFiles)
        for bandXmlFiles in xmlFilesByBand: 
            nBand = xmlFilesByBand.index(bandXmlFiles)
            tgo.write_lines_list('seq%i_band%i.lis' % (nSeq, nBand), bandXmlFiles)
            for file in bandXmlFiles: 
                print('Sequence %i, band %i, file %s' % (nSeq, nBand, file))

    return 1



if  __name__ == '__main__':
    main()