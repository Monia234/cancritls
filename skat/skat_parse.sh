#!/bin/sh

export LC_ALL=C
export LANG=C

function usage()
{
    cat << __EOS__
parse_result.sh: parse a result of "SKAT" R package.

usege: parse_result.sh resultfile genefile tblfile

__EOS__
}

if [ $# -ne 3 ]
then
    usage
    exit 1
fi

binary_path=$(dirname $0)
file=$1
filename=${file##*/}
gene=$2
genename=${gene##*/}
tbl=$3

Rscript $binary_path/dedigestID.r $file $tbl /tmp/$filename.dedigested
head -n1 $file > /tmp/$filename.header
cut -f1-4 $gene | sort -k1 > /tmp/$genename.sorted
nrow=$(( $(wc -l /tmp/$filename.dedigested | cut -d' ' -f1) - 1 ))
sed -e '1d' /tmp/$filename.dedigested | sort -k1 > /tmp/$filename.sorted
join -j1 /tmp/$genename.sorted /tmp/$filename.sorted > /tmp/$filename.joined
awk '{print $1,"Chr","Start","End",$2,$3,$4}' /tmp/$filename.header | cat - /tmp/$filename.joined | sed -e 's/ /\t/g' > $filename.parsed
