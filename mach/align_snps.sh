#!/bin/sh

ref=$1
file=$2
filename=${file##*/}
filename=${filename%.bim}

awk -v f=$filename 'NR==FNR{ref[$1,$4]="$5 $6";next}{if(ref[$1,$4] != "" && (ref[$1,$4] == "$5 $6" || ref[$1,$4] == "$6 $5")){print $2 > f".include"}else{print $2 > f".exclude"}}' $ref $file

