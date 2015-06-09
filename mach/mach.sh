#!/bin/sh

datfile=$2
pedfile=`echo $1 | sed 's/chunk[0-9]*-//'`
prefix=${datfile##*/}
prefix=${prefix%.dat}

mach -d $datfile -p $pedfile --rounds 20 --states 200 --phase --prefix $prefix --sample 5 > $prefix-mach.log

