#!/bin/sh

export LC_ALL=C
export LANG=C

binary_path="$(dirname $0)"
avinput=$1
avinput_name=${avinput##*/}
csv=$2
csv_name=${csv##*/}
bim=$3
bim_name=${bim##*/}

cut -f11 $avinput > /tmp/$avinput_name
csvquote $csv | cut -d',' -f7 | csvquote -u | sed -e '1d' -e 's/\"//g' > /tmp/$csv_name
paste /tmp/$csv_name /tmp/$avinput_name | sort -k2 | uniq > ${csv_name%.csv}.gene
nrow="$(wc -l $bim | cut -d' ' -f1)"
seq $nrow | paste $bim - | sort -k2 > /tmp/$bim_name
join -j2 /tmp/$bim_name ${csv_name%.csv}.gene > /tmp/${bim_name}.anno
sort -k7 -n /tmp/${bim_name}.anno | awk '{OFS="\t"}{print $2,$1,$3,$4,$5,$6,$8}' > ${bim_name}.anno

Rscript $binary_path/aggregate_anno.r ${bim_name}.anno ${bim_name}.gene

