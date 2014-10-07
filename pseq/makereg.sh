#!/bin/bash

function usage()
{
    cat << __EOS__
makereg.sh: make a .reg file for loc-load command from .gene file.

usage: makereg.sh genefile

__EOS__
}

if [ $# -ne 1 ]
then
    usage
    exit 1
fi

gene=$1
filename=${gene##*/}
filename=${filename%.bim.gene}

gawk '{OFS="\t"}{print "chr"$2,$3,$4,$1}' $gene | sed -e '1i\#CHR\tPOS1\tPOS2\tID' > ${filename}.reg

