#!/bin/bash

CMDNAME=$(basename $0)
BASEDIR=$(dirname $0)

separator() {
    for i in $(seq 1 ${COLUMNS:-80})
    do
        echo -n "="
    done
    echo ""
}

section() {
    separator
    echo $1
    separator
}

warning() {
    echo "$CMDNAME $1" 1>&2
}

usage_exit () {
    echo "Usage: $CMDNAME" 1>&2
    echo "       -s, --step [step" 1>&2
    echo "       --bfile [filename]" 1>&2
    echo "       -o,--out [prefix]" 1>&2
    echo "       --chr-(start|end) [chr]" 1>&2
    echo "       --mach-rounds [rounds]" 1>&2
    echo "       --mach-states [states]" 1>&2
    exit 1
}

# Error handling
set -e
# trap

OPT=$(getopt -o o:s: --long out:,step:,bfile:,chr-start:,chr-end:,chr-skip:,mach-rounds:,mach-states:,minimac-rounds:,minimac-states:,minimac-vcf-reference: -- "$@")
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
        -s | --step)
            STEP=$2
            shift ;;
        --bfile)
            BFILENAME=$(cd $(dirname $2) && pwd)/$(basename $2)
            shift ;;
        --chr-start)
            CHRSTART=$2
            shift ;;
        --chr-end)
            CHREND=$2
            shift ;;
        --chr-skip)
            CHRSKIP=$2
            shift ;;
        --mach-rounds)
            MACH_ROUNDS=$2
            shift ;;
        --mach-states)
            MACH_STATES=$2
            shift ;;
        --minimac-rounds)
            MINIMAC_ROUNDS=$2
            shift ;;
        --minimac-states)
            MINIMAC_STATES=$2
            shift ;;
        --minimac-vcf-reference)
            MINIMAC_VCF_REFERENCE=$2
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

STEP=${STEP:-1}
PREFIX=${PREFIX:-$(basename $BFILENAME)}
CHRSTART=${CHRSTART:-1}
CHREND=${CHREND:-22}
MACH_ROUNDS=${MACH_ROUNDS:-30}
MACH_STATES=${MACH_STATES:-400}
MINIMAC_ROUNDS=${MINIMAC_ROUNDS:-5}
MINIMAC_STATES=${MINIMAC_STATES:-200}

if [ ! -r "$BFILENAME.bed" ]
then
    warning "Cannot Read binary plink file $BFILENAME."
    exit 1
fi

section "01: Chunk"
if [ $STEP -le 1 ]
then
    mkdir -p 01_chunk
    cd 01_chunk

    for chr in $(seq $CHRSTART $CHRSKIP $CHREND)
    do
        plink --bfile $BFILENAME --chr $chr --recode --out $PREFIX.chr$chr
        $BASEDIR/ped2merlin.sh $PREFIX.chr$chr
        echo ''
    done

    cd ..
else
    echo "Skipped."
fi

section "02: Prephasing"
if [ $STEP -le 2 ]
then
    mkdir -p 02_prephasing
    cd 02_prephasing

    for chr in $(seq $CHRSTART $CHRSKIP $CHREND)
    do
        mach1 -d ../01_chunk/$PREFIX.chr$chr.merlin.dat -p ../01_chunk/$PREFIX.chr$chr.merlin.ped \
              --rounds $MACH_ROUNDS --states $MACH_STATES --phase \
              --interim 5 --sample 5 --prefix $PREFIX.chr$chr.haps
        echo ''
    done

    cd ..
else
    echo "Skipped."
fi

section "03: Imputation"
if [ $STEP -le 3 ]
then
    mkdir -p 03_imputation
    cd 03_imputation
    for chr in $(seq $CHRSTART $CHRSKIP $CHREND)
    do
        ref=$(echo $MINIMAC_VCF_REFERENCE | sed -e "s/@/$chr/")
        minimac2 --vcfReference --refHaps $ref \
                 --haps ../02_prephasing/$PREFIX.chr$chr.haps.gz \
                 --snps ../01_chunk/$PREFIX.chr$chr.merlin.snps \
                 --rounds $MINIMAC_ROUNDS \
                 --states $MINIMAC_STATES \
                 --prefix $PREFIX.chr$chr
        echo ''
    done
    cd ..
else
    echo "Skipped."
fi
