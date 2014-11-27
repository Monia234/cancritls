HapMap
=========

## unite_all_hapmap3.sh
Generate merged PLINK .bed file with all populations in HapMap3.

```{shell}
Usage: unite_all_hapmap3.sh [/path/to/hapmap3]
```

## subset_hapmap3.sh
Generate a PLINK .bed file, a subset of selected populations in HapMap3.

```{shell}
Usage: subset_hapmap3.sh /path/to/hapmap3 population ...
```

## merge_hapmap3.sh
Merge a given PLINK .bed file with selected populations in HapMap3. 

```{shell}
Usage: merge_hapmap3.sh /path/to/plinkbed /path/to/hapmap3 population ... 
```

## convert2merlin.sh
Convert a given HapMap dataset into merlin format (dat/map/ped).

```{shell}
Usage: convert2merlin.sh /path/to/hapmap template
```

## convert2ped.sh
Convert a given HapMap dataset into PLINK ped format (ped/map).

```{shell}
Usage: convert2ped.sh /path/to/hapmap
```

## qc4impute.sh
Filter tri+allelic/monomorphic alleles for later imputation process.

```{shell}
Usage: qc4impute.sh /path/to/hapmap
```


## Before Imputation Procedure

0. Retrieve HapMap dataset
1. QC: Run qc4impute.sh
2. Divide into contig regions: Run split_contigs_b36.sh
3. Convert to MERLIN format: Run convert2merlin.sh
4. Phasing: Run phase.sh


