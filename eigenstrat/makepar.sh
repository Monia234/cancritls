#!/bin/sh

file=${1%.bed}
filename=${file##*/}
numoutevec=${2:-'10'}

cat << _EOT_ > ${filename}.par
genotypename:   ${file}.bed
snpname:    ${file}.bim
indivname:  ${file}.fam
evecoutname:    ${filename}.evec
evaloutname:    ${filename}.eval
altnormstyle:   NO
numoutevec: ${numoutevec}
familynames:    YES
grmoutname: ${filename}.grmjunk

_EOT_

