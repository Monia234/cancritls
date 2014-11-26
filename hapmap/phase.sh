#!/bin/sh

hapmapdir=${1%/}

for f in `ls $hapmapdir`
do
    if [ ${f##*.} == "dat" ]
    then
        filename=${f%.dat}
        echo $filename
        mach -d $hapmapdir/$filename.dat -p $hapmapdir/$filename.ped --rounds 50 --states 200 --phase --prefix $filename
    fi
done
