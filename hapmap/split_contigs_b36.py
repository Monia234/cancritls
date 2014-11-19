#!/usr/bin/env python
import glob
import os.path
import shlex
import sys
import subprocess
import re

def parse_contigs(file):
    contigs = {}
    with open(file, 'r') as f:
        for line in f:
            chrom, contig, start, end = line.strip('\n').split('\t')
            contigs.setdefault(chrom, {})[contig] = (start, end)
    return contigs

def main():
    hapmapdir = sys.argv[1]
    contigs_file = sys.argv[2]
    contigs = parse_contigs(contigs_file)

    ptn = re.compile("chr([0-9]+)")
    gawk = "gawk -F' ' '{{if (NR == 1 || ({0} <= $4 && $4 <= {1})){{print $0}}}}' {2}"

    for file in glob.glob(hapmapdir + "/*"):
        filename = os.path.basename(file)
        print(filename)
        chrom = ptn.findall(filename)
        if (len(chrom) <= 0 or os.path.isdir(file)):
            continue
        chrom = chrom[0]
        for k, v in contigs[chrom].items():
            output = ptn.sub("chr"+k, filename)
            with open(output, "w") as f:
                proc = subprocess.Popen(shlex.split(gawk.format(v[0], v[1], file)), env = os.environ, stdout = f, stderr = subprocess.PIPE)
            stdout, stderr = proc.communicate()
            ret = proc.returncode

if __name__ == '__main__':
    main()

