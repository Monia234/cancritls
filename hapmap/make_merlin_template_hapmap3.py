#!/usr/bin/env python
import sys

def main():
    file = sys.argv[1]
    with open(file, "r") as f:
        f.readline()
        for line in f:
            fid, iid, dad, mam, sex, pheno, pop = line.strip('\n').split('\t')
            niid = iid.lstrip('NA')
            if (fid == iid):
                print('\t'.join(("", iid, dad, mam, sex, pop+niid, iid)))
            else:
                print('\t'.join((fid, iid, dad, mam, sex, pop+fid+"."+niid, iid)))

if __name__ == '__main__':
    main()

