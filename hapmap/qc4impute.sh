#!/bin/sh

hapmapdir=${1%/*}

mkdir -p ped
for i in `ls $hapmapdir`
do
    filename=${i%.txt}
    pfilename=./ped/$filename
    echo $filename
    glu transform $hapmapdir/$i -o ${pfilename}.ped:map=${pfilename}.map -f hapmap
    plink --file $pfilename --maf 1e-100 --write-snplist --out $pfilename
    awk 'FNR==1;FNR==NR{a[$1];next}$1 in a{print $0}' ${pfilename}.snplist $hapmapdir/$i | sed -e '1d' > $filename.qc.txt
done

