#!/bin/sh

length=5000
overlap=500

file=$1
filename=${file##*/}

for i in `seq 1 22`
do
    awk -v i=$i 'OFS="\t"{if ($1==i){print "M",$2}}' $file.chr$i.map > $filename.chr$i.dat
    ChunkChromosome -d $filename.chr$i.dat -n $length -o $overlap
done

