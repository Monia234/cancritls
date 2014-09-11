#!/bin/bash

binary_path=`dirname $0`
file=${1%.bed}
filename=${file##*/}
hapmap_path=$2

plink --bfile $file --write-snplist --out $filename
$binary_path/subset_hapmap3.sh $hapmap_path ${@:3}

population=`echo ${@:3} | sed -e 's/ /_/g'`
hapmap_file=hapmap3_r3_b36_fwd.$population.qc.poly

plink --bfile $hapmap_file --extract $filename.snplist --make-bed --out $hapmap_file.extracted
$binary_path/../plink/align_position.sh $hapmap_file.extracted $file

plink --bfile $hapmap_file.extracted --exclude $hapmap_file.extracted.exclude --make-bed --out $hapmap_file.aligned
plink --bfile $hapmap_file.aligned --bmerge $file --out $filename.hapmap3_$population
