#!/bin/bash

# wget -q ftp://ftp.ncbi.nlm.nih.gov/hapmap/genotypes/2010-05_phaseIII/plink_format/hapmap3_r3_b36_fwd.qc.poly.tar.gz
# tar xzvf hapmap3_r3_b36_fwd.qc.poly.tar.gz

i=11
echo -n "" > mergelist.txt
echo -e "Phenotype\tPopulation" > population.txt
for f in `find *.ped`
do
    file=${f%.ped}
    plink --file $file --make-bed --out $file
    mv $file.fam $file.fam.old
    cut -d' ' -f1-5 $file.fam.old | gawk -v i=$i '{print $0, i}' > $file.fam  
    echo $file >> mergelist.txt
    echo $file | gawk -v i=$i 'OFS="\t"{print gensub(/hapmap3_r3_b36_fwd\.([A-Z]+)\.qc\.poly/,"\\1",""), i}' >> population.txt
    i=`expr $i + 10`
done

plink --merge-list mergelist.txt --make-bed --out hapmap_r3_b36_fwd.ALL.qc.poly
