#/bin/sh

hapmapdir=$1
template=$HOME/src/merlin-1.1.2/examples/HapMap.template

for i in `ls $hapmapdir`
do
    filename=${i%.txt}
    echo $filename
    hapmapConverter -t$template -g$hapmapdir/$i -m${filename}.map -d${filename}.dat -p ${filename}.ped -c+
done

