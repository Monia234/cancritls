#!/bin/bash

CMDNAME=$(basename $0)

warning() {
    echo "$CMDNAME $1" 1>&2
}

usage_exit () {
    echo "Usage: $CMDNAME" 1>&2
    echo "       -o,--out,--prefix [prefix]" 1>&2
    echo "       -d, --dat [datfile]" 1>&2
    echo "       -p, --ped [pedfile]" 1>&2
    echo "       --rounds [rounds]" 1>&2
    echo "       --states [states]" 1>&2
    echo "       --args [args]" 1>&2
    exit 1
}

# Error handling
set -e
# trap

OPT=$(getopt -o d:p:o: --long dat:,ped:,out:,prefix:,rounds:,states:,args: -- "$@")
if [ $? != 0 ]
then
    usage_exit
fi
eval set -- "$OPT"

while true
do
    case "$1" in
        -o | --out | --prefix)
            PREFIX=$2
            shift ;;
        -d | --dat)
            DAT=$2
            shift ;;
        -p | --ped)
            PED=$2
            shift ;;
        --rounds)
            ROUNDS=$2
            shift ;;
        --states)
            STATES=$2
            shift ;;
        --args)
            ARGS=$2
            shift ;;
        --)
            shift
            break ;;
        -*)
            warning "Unrecognized Option $1"
            usage_exit ;;
        *)
            usage_exit ;;
    esac
    shift
done

PREFIX=${PREFIX:-output}
ROUNDS=${ROUNDS:-20}
STATES=${STATES:-200}

mach1 -d $DAT -p $PED --rounds $ROUNDS --states $STATES --phase --interim 5 --sample 5 --prefix $PREFIX $ARGS

