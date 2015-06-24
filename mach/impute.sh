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
    echo "       -o,--out [prefix]" 1>&2
    echo "       -s, --step [step]" 1>&2
    echo "       --scheduler [scheduler]" 1>&2
    echo "       --bfile [filename]" 1>&2
    echo "       --chr-(start|end) [chr]" 1>&2
    echo "       --chr-skip [skip]" 1>&2
    echo "       --split-sex" 1>&2
    echo "       --chunk-chromosome" 1>&2
    echo "       --plink-args [args]" 1>&2
    echo "       --mach-rounds [rounds]" 1>&2
    echo "       --mach-states [states]" 1>&2
    echo "       --mach-args [args]" 1>&2
    echo "       --minimac-rounds [rounds]" 1>&2
    echo "       --minimac-states [states]" 1>&2
    echo "       --minimac-vcf-reference [reference]" 1>&2
    echo "       --minimac-args [args]" 1>&2
    exit 1
}

# get lsf jobid
get_jobid () {
    output=$($*)
    export OUTPUT=$output
    echo $output | grep "^Job <[0-9]*>" | cut -d'<' -f2 | cut -d'>' -f1
}

# Error handling
set -e
# trap

OPT=$(getopt -o o:s: --long out:,step:,scheduler:,bfile:,chr-start:,chr-end:,chr-skip:,split-sex,chunk-chromosome,plink-args:,mach-rounds:,mach-states:,mach-args:,minimac-rounds:,minimac-states:,minimac-vcf-reference:,minimac-args: -- "$@")
if [ $? != 0 -o $# -lt 1 ]
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
        --scheduler)
            SCHEDULER=$2
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
        --split-sex)
            SPLIT_SEX=1 ;;
        --chunk-chromosome)
            CHUNK_CHROMOSOME=1 ;;
        --plink-args)
            PLINK_ARGS=$2
            shift ;;
        --rs)
            RSID=1 ;;
        --mach-rounds)
            MACH_ROUNDS=$2
            shift ;;
        --mach-states)
            MACH_STATES=$2
            shift ;;
        --mach-args)
            MACH_ARGS=$2
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
        --minimac-args)
            MINIMAC_ARGS=$2
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

if [ ! -r "$BFILENAME.bed" ]
then
    warning "Cannot Read binary plink file $BFILENAME."
    exit 1
fi

PREFIX=${PREFIX:-$(basename $BFILENAME)}
STEP=${STEP:-1}
SCHEDULER=${SCHEDULER:-bsubp}
CHRSTART=${CHRSTART:-1}
CHREND=${CHREND:-22}
SPLITSEX=${SPLITSEX:-0}
CHUNK_CHROMOSOME=${CHUNK_CHROMOSOME:-0}
CHUNK_CHROMOSOME_LENGTH=${CHUNK_CHROMOSOME_LENGTH:-2500}
CHUNK_CHROMOSOME_OVERLAP=${CHUNK_CHROMOSOME_OVERLAP:-500}
MACH_ROUNDS=${MACH_ROUNDS:-20}
MACH_STATES=${MACH_STATES:-200}
MINIMAC_ROUNDS=${MINIMAC_ROUNDS:-5}
MINIMAC_STATES=${MINIMAC_STATES:-200}

# array for jobid
declare -A jobid_

section "01: Chunk"
if [ $STEP -le 1 ]
then
    mkdir -p 01_chunk
    cd 01_chunk

    if [ $CHUNK_CHROMOSOME -eq 1 ]
    then
        mkdir -p chunkchromosome
    fi

    for chr in $(seq $CHRSTART $CHRSKIP $CHREND)
    do
        prefix=$PREFIX.chr$chr
        plink --bfile $BFILENAME --chr $chr --recode --out $prefix $PLINK_ARGS
        $BASEDIR/ped2merlin.sh $prefix
        if [ $CHUNK_CHROMOSOME -eq 1 ]
        then
            cd chunkchromosome
            # awk '{OFS="\t"}{print "M", $1":"$4"}' ../$prefix.map > $prefix.merlin.dat
            ChunkChromosome -d $prefix.merlin.dat -n $CHUNK_CHROMOSOME_LENGTH -o $CHUNK_CHROMOSOME_OVERLAP
            cd ..
        fi
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
        prefix=$PREFIX.chr$chr

        if [ $CHUNK_CHROMOSOME -ne 1 ]
        then
            jobcmd="mach1 -d ../01_chunk/$prefix.merlin.dat -p ../01_chunk/$prefix.merlin.ped --rounds $MACH_ROUNDS --states $MACH_STATES --phase --interim 5 --sample 5 --prefix $prefix.haps $MACH_ARGS"
            if [ $SCHEDULER == "bsubp" ]
            then
                jobid_[$prefix.mach1]=$(get_jobid bsub -o $prefix.mach1.stdout -e $prefix.mach1.stderr -J $prefix.mach1 -q sg_h "$jobcmd")
                echo $OUTPUT
            else
                eval "$jobcmd"
            fi
        else
            for chunk in $(ls ../01_chunk/chunkchromosome/chunk*-$prefix.merlin.dat)
            do
                chunknum=${chunk##*/}
                chunknum=${chunknum%*-$prefix.merlin.dat}
                jobcmd="mach1 -d $chunk -p ../01_chunk/$prefix.merlin.ped --rounds $MACH_ROUNDS --states $MACH_STATES --phase --interim 5 --sample 5 --prefix $chunknum-$prefix.haps $MACH_ARGS"
                if [ $SCHEDULER == "bsubp" ]
                then
                    jobid_[$prefix.$chunknum.mach1]=$(get_jobid bsub -o $prefix.$chunknum.mach1.stdout -e $prefix.$chunknum.mach1.stderr -J $prefix.$chunknum.mach1 -q sg_h "$jobcmd")
                    echo $OUTPUT
                else
                    eval "$jobcmd"
                fi
            done
        fi
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
        prefix=$PREFIX.chr$chr
        ref=$(echo $MINIMAC_VCF_REFERENCE | sed -e "s/@/$chr/")
        if [ ! -r "$ref" ]
        then
            warning "Cannot Read $MINIMAC_VCF_REFERENCE."
            exit 1
        fi

        if [ $CHUNK_CHROMOSOME -ne 1 ]
        then
            jobcmd="minimac2 --vcfReference --refHaps $ref --haps ../02_prephasing/$prefix.haps.gz --snps ../01_chunk/$prefix.merlin.snps --rounds $MINIMAC_ROUNDS --states $MINIMAC_STATES --prefix $prefix $MINIMAC_ARGS"
            if [ $SCHEDULER == "bsubp" ]
            then
                jobid_[$prefix.minimac2]=$(get_jobid bsub -o $prefix.minimac2.stdout -e $prefix.minimac2.stderr -J $prefix.minimac2 -q sg_h -w "done(${jobid_[$prefix.mach1]})" "$jobcmd")
                echo $OUTPUT
            else
                eval "$jobcmd"
            fi
        else
            for chunk in $(ls ../01_chunk/chunkchromosome/chunk*-$prefix.merlin.dat)
            do
                chunknum=${chunk##*/}
                chunknum=${chunknum%*-$prefix.merlin.dat}
                jobcmd="minimac2 --vcfReference --refHaps $ref --haps ../02_prephasing/$chunknum-$prefix.haps.gz --snps ../01_chunk/chunkchromosome/$chunknum-$prefix.merlin.dat.snps --rounds $MINIMAC_ROUNDS --states $MINIMAC_STATES --prefix $chunknum-$prefix $MINIMAC_ARGS"
                if [ $SCHEDULER == "bsubp" ]
                then
                    jobid_[$prefix.$chunknum.minimac2]=$(get_jobid bsub -o $prefix.$chunknum.minimac2.stdout -e $prefix.$chunknum.minimac2.stderr -J $prefix.$chunknum.minimac2 -q sg_h -w "done(${jobid_[$prefix.$chunknum.mach1]})" "$jobcmd")
                    # bsubp -p $prefix.$chunknum.minimac2 -J $prefix.$chunknum.minimac2 "$jobcmd"
                    echo $OUTPUT
                else
                    eval "$jobcmd"
                fi
            done
        fi
        echo ''
    done
    cd ..
else
    echo "Skipped."
fi
