#!/bin/bash

file=$1
filename=$(basename $file)
filename=${file%.*}
chr=${filename#*.chr}

cat $file | awk -v pat=^$chr: 'NR==30{print $0};NR>30{if($2 ~ pat){print $0}}' > $filename.assoc
