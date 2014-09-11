#!/bin/bash

hapmap_path=${1%/}
echo -n '' > mergelist.txt
for i in `seq 2 $#`
do
    echo -e $hapmap_path/hapmap3_r3_b36_fwd.${@:$i:1}.qc.poly >> mergelist.txt
done

population=`echo ${@:2} | sed -e 's/ /_/g'`
plink --merge-list mergelist.txt --out hapmap3_r3_b36_fwd.$population.qc.poly

