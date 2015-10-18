#!/bin/sh

file=${1%.bed}
filename=$(basename $file)
numoutevec=${2:-'10'}

smartpca.perl -i ${file}.bed -a ${file}.bim -b ${file}.fam -k ${numoutevec} -o ${filename}.pca -p ${filename}.plot -e ${filename}.eval -l ${filename}.smartpca.log

