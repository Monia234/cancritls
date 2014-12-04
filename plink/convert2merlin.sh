#!/bin/sh

function usage()
{
    cat << __EOS__
convert2merlin.sh: convert a given PLINK dataset(ped/map) into MERLIN format (ped/dat/map).

usage: convert2merlin.sh /path/to/file
__EOS__
}


if [ $# -lt 1 ]
then
    usage
    exit 1
fi

file=$1
filename=${1##*/}

cut -d' ' -f6 --complement $file.ped > $filename.merlin.ped
cut -f3 --complement $file.map | sed -e '1iCHROMOSOME\tMARKER\tPOSITION' > $filename.merlin.map
cut -f2 $file.map | awk 'OFS="\t"{print "M", $0}' > $filename.merlin.dat

