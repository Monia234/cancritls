#!/bin/sh

file=$1
fam=$2
if [ -z $fam ]
then
    fam=${1:.pca.evec}.fam
fi
k=${3:-'9999'}

cat $file | awk '{NF--; print}' | sed -e '1d' -e 's/:/\t/' > /tmp/${file}.parsed
join -j2 $fam /tmp/${file}.parsed | cut -d' ' -f7- --complement | awk '{print $2,$1,$3,$4,$5,$6}' > ${file}.parsed.fam
cut -d' ' -f2- /tmp/${file}.parsed | cut -d' ' -f1-$k > ${file}.parsed

