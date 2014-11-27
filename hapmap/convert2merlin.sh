#!/bin/sh

function usage()
{
    cat << __EOS__
convert2merlin.sh: convert a given HapMap dataset into MERLIN format (ped/dat/map).

usage: convert2merlin.sh /path/to/hapmap /path/to/template
__EOS__
}

hapmapdir=${1%/*}
template=$2

if [ $# -lt 2 ]
then
    usage
    exit 1
fi

for i in `ls -F $hapmapdir | grep -v /`
do
    filename=${i%.txt}
    echo $filename
    hapmapConverter -t $template -g $hapmapdir/$i -m ${filename}.map -d ${filename}.dat -p ${filename}.ped -c +
done

