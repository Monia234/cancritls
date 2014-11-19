#/bin/sh

hapmapdir=$1
template=$2

for i in `ls $hapmapdir`
do
    filename=${i%.txt}
    echo $filename
    hapmapConverter -t $template -g $hapmapdir/$i -m ${filename}.map -d ${filename}.dat -p ${filename}.ped -c +
done

