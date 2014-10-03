#!/bin/sh

anno=$1
filename=${anno%.bim.anno}
filename=${filename##*/}

awk '{OFS="\t"}{print $7, $2}' $anno > /tmp/$filename.SetID
Rscript digestID.r /tmp/$filename.SetID $filename.SetID $filename.SetID.digestbl

