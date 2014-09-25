#!/bin/sh

binary_path=$(dirname $0)
file=${1%.ccmatch}
fam=$2
famname=${fam##*/}
tmp="/tmp/$file.ccmatch.parsed"
echo -n '' > $tmp

for i in `seq 3`
do
    cut -f $i $file.ccmatch >> $tmp
done

sort -n $tmp > $file.ccmatch.index
Rscript ${binary_path}/makefam.r $fam $file.ccmatch.index ${file}.ccmatch.keep

