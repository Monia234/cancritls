#!/bin/sh

function usage()
{
    cat << __EOS__
    makeSetID.sh: make a .SetID file from .anno file for "SKAT" R package.

usage: makeSetID.sh annofile

__EOS__
}

if [ $# -ne 1 ]
then
    usage
    exit 1
fi

binary_path=$(dirname $0)
anno=$1
filename=${anno%.bim.anno}
filename=${filename##*/}

awk '{OFS="\t"}{print $7, $2}' $anno > /tmp/$filename.SetID
Rscript $binary_path/digestID.r /tmp/$filename.SetID $filename.SetID $filename.SetID.digestbl

