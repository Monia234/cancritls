#!/bin/sh

hapmapdir=${1%/}

for i in `ls -F $hapmapdir | grep -v /`
do
    filename=${i%.txt}
    echo $filename
    glu transform $hapmapdir/$i -o ${filename}.ped:map=${filename}.map -f hapmap
done

