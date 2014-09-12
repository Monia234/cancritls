logdir=${1%/}
grep -h 'CV' $logdir/log*.out | gawk '{print gensub(/CV error \(K=([0-9]*)\): ([0-9\.]*)/, "\\1\t\\2","")}' | sort -V | sed -e '1i\K\tCV' > $logdir/kcv.log
cat $logdir/kcv.log

