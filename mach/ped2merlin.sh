#!/bin/bash

CMDNAME=$(basename $0)

warning() {
    echo "$CMDNAME: $1" 1>&2
}

usage_exit () {
    warning "Usage: $CMDNAME [filename]"
    warning "       -p, --ped [pedname]"
    warning "       -m, --map [mapname]"
    warning "       -d [delimiter]"
    warning "       -o, --out [prefix]"
    warning "       --rs"
    exit 1
}

OPT=$(getopt -o p:m:d:o: --long ped:,map:,out:,rs -- "$@")
if [ $? != 0 ]
then
    usage_exit
fi
eval set -- "$OPT"

while true
do
    case "$1" in
        -o | --out)
            PREFIX=$2
            shift ;;
        -p | --ped)
            PED=$2
            shift ;;
        -m | --map)
            MAP=$2
            shift ;;
        -d)
            DELIMITER=$2
            shift ;;
        --rs)
            RS_FLAG=1 ;;
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

set -e

if [ -n "$1" ]
then
    FILENAME=$(basename $1)
    if [ -z "$PED" ]
    then
        PED="$1.ped"
    fi
    if [ -z "$MAP" ]
    then
        MAP="$1.map"
    fi
    if [ -z "$PREFIX" ]
    then
        PREFIX="$FILENAME"
    fi
fi
PREFIX=${PREFIX:-output}
DELIMITER=${DELIMITER:-' '}
RS_FLAG=${RS_FLAG:-0}


if [ -r "$PED" ]
then
    cut -f6 --complement -d "$DELIMITER" $PED > $PREFIX.merlin.ped
else
    warning "Cannot Read $PED."
    exit 1
fi

if [ -r "$MAP" ]
then
    if [ $RS_FLAG -eq 1 ]
    then
        awk '{OFS="\t"}{print "M", $2}' $MAP > $PREFIX.merlin.dat
    else
        awk '{OFS="\t"}{print "M", $1":"$4}' $MAP > $PREFIX.merlin.dat
    fi
    cut -f2 $PREFIX.merlin.dat > $PREFIX.merlin.snps
else
    warning "Cannot Read $MAP."
    exit 1
fi

